import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import '../models/documento_cliente.dart';

class DocumentoClienteService {
  DocumentoClienteService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  String _base(int idCliente) => '${ApiConfig.clientes}/$idCliente/documentos';

  Future<List<DocumentoCliente>> getAll(int idCliente) async {
    final json = await _apiClient.getJson(_base(idCliente));
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .map((item) => DocumentoCliente.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<TipoDocumentoCliente>> getTypes(int idCliente) async {
    final json = await _apiClient.getJson('${_base(idCliente)}/tipos');
    final data = json['data'];
    if (data is! List) return const [];
    return data
        .map(
          (item) => TipoDocumentoCliente.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  Future<DocumentoCliente> upload({
    required int idCliente,
    required int idTipoDocumento,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    final json = await _apiClient.multipart(
      _base(idCliente),
      bytes: bytes,
      fileName: fileName,
      contentType: contentType,
      fields: {'idTipoDocumento': '$idTipoDocumento'},
    );
    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        message: 'La API no devolvió el documento creado.',
      );
    }
    return DocumentoCliente.fromJson(data);
  }

  Future<void> delete(int idCliente, int idDocumento) async {
    await _apiClient.deleteJson('${_base(idCliente)}/$idDocumento');
  }
}

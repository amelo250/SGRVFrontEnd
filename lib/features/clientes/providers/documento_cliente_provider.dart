import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import '../models/documento_cliente.dart';
import '../services/documento_cliente_service.dart';

class DocumentoClienteProvider extends ChangeNotifier {
  DocumentoClienteProvider({DocumentoClienteService? service})
    : _service = service ?? DocumentoClienteService();

  final DocumentoClienteService _service;
  List<DocumentoCliente> documentos = const [];
  List<TipoDocumentoCliente> tipos = const [];
  bool loading = false;
  bool mutating = false;
  String? error;
  Map<String, String>? imageHeaders;

  Future<void> load(int idCliente) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await Future.wait<Object>([
        _service.getAll(idCliente),
        _service.getTypes(idCliente),
      ]);
      documentos = result[0] as List<DocumentoCliente>;
      tipos = result[1] as List<TipoDocumentoCliente>;
      final token = await TokenStorage.getToken();
      imageHeaders = token == null || token.isEmpty
          ? null
          : {'Authorization': 'Bearer $token'};
    } on ApiException catch (exception) {
      error = exception.message;
    } catch (_) {
      error = 'No fue posible cargar los documentos del cliente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> upload({
    required int idCliente,
    required int idTipoDocumento,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    mutating = true;
    error = null;
    notifyListeners();
    try {
      await _service.upload(
        idCliente: idCliente,
        idTipoDocumento: idTipoDocumento,
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
      );
      await load(idCliente);
      return true;
    } on ApiException catch (exception) {
      error = exception.message;
      return false;
    } catch (_) {
      error = 'No fue posible cargar el documento.';
      return false;
    } finally {
      mutating = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int idCliente, int idDocumento) async {
    mutating = true;
    error = null;
    notifyListeners();
    try {
      await _service.delete(idCliente, idDocumento);
      await load(idCliente);
      return true;
    } on ApiException catch (exception) {
      error = exception.message;
      return false;
    } catch (_) {
      error = 'No fue posible eliminar el documento.';
      return false;
    } finally {
      mutating = false;
      notifyListeners();
    }
  }
}

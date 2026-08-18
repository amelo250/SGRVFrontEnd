import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';

class EmpresaService {
  EmpresaService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();
  final ApiClient _api;
  Future<List<Empresa>> getEmpresas() async {
    final response = ApiResponse<List<Empresa>>.fromJson(
      await _api.getJson(ApiConfig.empresas),
      (v) => (v as List)
          .map((x) => Empresa.fromJson(x as Map<String, dynamic>))
          .toList(),
    );
    _ok(response.success, response.message);
    return response.data ?? const [];
  }

  Future<Empresa> getCurrent() async =>
      _company(await _api.getJson('${ApiConfig.empresas}/actual'));
  Future<Empresa> onboarding({
    required List<int> logo,
    required String fileName,
    required String contentType,
    required String nombre,
    required String nombreComercial,
    required String rnc,
    required int idPlan,
    String? telefono,
    String? correo,
    String? direccion,
  }) async => _company(
    await _api.multipart(
      '${ApiConfig.empresas}/onboarding',
      bytes: logo,
      fileName: fileName,
      contentType: contentType,
      fileField: 'logo',
      fields: {
        'nombre': nombre,
        'nombreComercial': nombreComercial,
        'rnc': rnc,
        'idPlan': '$idPlan',
        if (telefono?.trim().isNotEmpty == true) 'telefono': telefono!.trim(),
        if (correo?.trim().isNotEmpty == true) 'correo': correo!.trim(),
        if (direccion?.trim().isNotEmpty == true)
          'direccion': direccion!.trim(),
      },
    ),
  );
  Future<Empresa> _company(Map<String, dynamic> json) async {
    final r = ApiResponse<Empresa>.fromJson(
      json,
      (v) => Empresa.fromJson(v as Map<String, dynamic>),
    );
    _ok(r.success, r.message);
    if (r.data == null) {
      throw const ApiException(message: 'La API no devolvió la empresa.');
    }
    return r.data!;
  }

  static void _ok(bool ok, String message) {
    if (!ok) throw ApiException(message: message);
  }

  void dispose() => _api.dispose();
}

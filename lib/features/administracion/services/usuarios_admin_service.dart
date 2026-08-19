import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import '../models/usuario_admin.dart';

class UsuariosAdminService {
  UsuariosAdminService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;
  Future<List<UsuarioAdmin>> getAll({int? idEmpresa}) async {
    final uri = Uri.parse(ApiConfig.usuarios).replace(
      queryParameters: {if (idEmpresa != null) 'idEmpresa': '$idEmpresa'},
    );
    final response = ApiResponse<List<UsuarioAdmin>>.fromJson(
      await _client.getJson(uri.toString()),
      (value) => (value as List<dynamic>)
          .map((x) => UsuarioAdmin.fromJson(x as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  Future<void> setActive(int id, bool active) async {
    await _client.patchJson('${ApiConfig.usuarios}/$id/estado?activo=$active');
  }

  Future<List<RolAdminOption>> getRoles() async {
    final response = ApiResponse<List<RolAdminOption>>.fromJson(
      await _client.getJson(ApiConfig.administracionRoles),
      (value) => (value as List<dynamic>)
          .map((x) => RolAdminOption.fromJson(x as Map<String, dynamic>))
          .toList(growable: false),
    );
    if (!response.success) throw ApiException(message: response.message);
    return response.data ?? const [];
  }

  Future<UsuarioAdmin> create({
    required String nombre,
    required String telefono,
    required int idEmpresa,
    required int idRol,
    required String email,
    required String password,
  }) async {
    final response = ApiResponse<UsuarioAdmin>.fromJson(
      await _client.postJson(ApiConfig.usuarios, {
        'nombre': nombre.trim(),
        'telefono': telefono.trim(),
        'idEmpresa': idEmpresa,
        'idRol': idRol,
        'email': email.trim(),
        'passwordHash': password,
        'activo': true,
      }),
      (value) => UsuarioAdmin.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}

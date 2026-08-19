class UsuarioAdmin {
  const UsuarioAdmin({
    required this.idUsuario,
    required this.idEmpresa,
    required this.idRol,
    required this.nombre,
    required this.email,
    required this.activo,
  });
  final int idUsuario, idEmpresa, idRol;
  final String nombre, email;
  final bool activo;
  factory UsuarioAdmin.fromJson(Map<String, dynamic> json) => UsuarioAdmin(
    idUsuario: (json['idUsuario'] as num?)?.toInt() ?? 0,
    idEmpresa: (json['idEmpresa'] as num?)?.toInt() ?? 0,
    idRol: (json['idRol'] as num?)?.toInt() ?? 0,
    nombre: json['nombre']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    activo: json['activo'] as bool? ?? false,
  );
}

class RolAdminOption {
  const RolAdminOption({
    required this.id,
    required this.codigo,
    required this.nombre,
  });
  final int id;
  final String codigo, nombre;
  factory RolAdminOption.fromJson(Map<String, dynamic> json) => RolAdminOption(
    id: (json['id'] as num?)?.toInt() ?? 0,
    codigo: json['code']?.toString() ?? '',
    nombre: json['name']?.toString() ?? '',
  );
}

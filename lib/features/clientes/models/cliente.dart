class Cliente {
  const Cliente({
    required this.idCliente,
    required this.idEmpresa,
    required this.nombre,
    required this.apellido,
    required this.cedulaPasaporte,
    required this.fechaNacimiento,
    required this.activo,
    required this.fechaCreacion,
    this.telefono,
    this.email,
    this.direccion,
    this.nacionalidad,
    this.licenciaConducir,
    this.fechaExpLicencia,
    this.fechaVencLicencia,
  });

  final int idCliente;
  final int idEmpresa;
  final String nombre;
  final String apellido;
  final String cedulaPasaporte;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? nacionalidad;
  final String? licenciaConducir;
  final DateTime? fechaExpLicencia;
  final DateTime? fechaVencLicencia;
  final bool activo;
  final DateTime fechaCreacion;

  String get nombreCompleto => '$nombre $apellido'.trim();

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: (json['idCliente'] as num).toInt(),
      idEmpresa: (json['idEmpresa'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      cedulaPasaporte: json['cedulaPasaporte']?.toString() ?? '',
      fechaNacimiento:
          DateTime.tryParse(json['fechaNacimiento']?.toString() ?? '') ??
          DateTime(1900),
      telefono: _stringOrNull(json['telefono']),
      email: _stringOrNull(json['email']),
      direccion: _stringOrNull(json['direccion']),
      nacionalidad: _stringOrNull(json['nacionalidad']),
      licenciaConducir: _stringOrNull(json['licenciaConducir']),
      fechaExpLicencia: _dateOrNull(json['fechaExpLicencia']),
      fechaVencLicencia: _dateOrNull(json['fechaVencLicencia']),
      activo: json['activo'] as bool? ?? false,
      fechaCreacion:
          DateTime.tryParse(json['fechaCreacion']?.toString() ?? '') ??
          DateTime(1900),
    );
  }

  static String? _stringOrNull(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _dateOrNull(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date == null || date.year <= 1 ? null : date;
  }
}

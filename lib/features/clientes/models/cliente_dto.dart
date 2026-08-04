class ClienteDto {
  const ClienteDto({
    required this.nombre,
    required this.apellido,
    required this.cedulaPasaporte,
    required this.fechaNacimiento,
    required this.licenciaConducir,
    required this.fechaExpLicencia,
    required this.fechaVencLicencia,
    this.telefono,
    this.email,
    this.direccion,
    this.nacionalidad,
  });

  final String nombre;
  final String apellido;
  final String cedulaPasaporte;
  final DateTime fechaNacimiento;
  final String? telefono;
  final String? email;
  final String? direccion;
  final String? nacionalidad;
  final String licenciaConducir;
  final DateTime fechaExpLicencia;
  final DateTime fechaVencLicencia;

  Map<String, dynamic> toJson() => {
    'nombre': nombre.trim(),
    'apellido': apellido.trim(),
    'cedulaPasaporte': cedulaPasaporte.trim(),
    'fechaNacimiento': _dateOnly(fechaNacimiento),
    'telefono': _nullable(telefono),
    'email': _nullable(email),
    'direccion': _nullable(direccion),
    'nacionalidad': _nullable(nacionalidad),
    'licenciaConducir': licenciaConducir.trim(),
    'fechaExpLicencia': _dateOnly(fechaExpLicencia),
    'fechaVencLicencia': _dateOnly(fechaVencLicencia),
  };

  static String _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day).toIso8601String();

  static String? _nullable(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

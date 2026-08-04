class ProveedorVehiculoDto {
  const ProveedorVehiculoDto({
    required this.nombre,
    required this.rncCedula,
    this.telefono,
    this.direccion,
    this.contacto,
    this.observacion,
    this.activo,
  });

  final String nombre;
  final String rncCedula;
  final String? telefono;
  final String? direccion;
  final String? contacto;
  final String? observacion;
  final bool? activo;

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'nombre': nombre,
      'rncCedula': rncCedula,
      'telefono': telefono,
      'direccion': direccion,
      'contacto': contacto,
      'observacion': observacion,
    };
    if (activo != null) json['activo'] = activo;
    return json;
  }
}

class ProveedorVehiculo {
  const ProveedorVehiculo({
    required this.idProveedorVehiculo,
    required this.nombre,
    required this.rncCedula,
    required this.activo,
    required this.fechaCreacion,
    this.telefono,
    this.direccion,
    this.contacto,
    this.observacion,
    this.fechaActualizacion,
  });

  final int idProveedorVehiculo;
  final String nombre;
  final String rncCedula;
  final String? telefono;
  final String? direccion;
  final String? contacto;
  final String? observacion;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;

  factory ProveedorVehiculo.fromJson(Map<String, dynamic> json) {
    return ProveedorVehiculo(
      idProveedorVehiculo: (json['idProveedorVehiculo'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      rncCedula: json['rncCedula']?.toString() ?? '',
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      contacto: json['contacto']?.toString(),
      observacion: json['observacion']?.toString(),
      activo: json['activo'] as bool? ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      fechaActualizacion: DateTime.tryParse(
        json['fechaActualizacion']?.toString() ?? '',
      ),
    );
  }
}

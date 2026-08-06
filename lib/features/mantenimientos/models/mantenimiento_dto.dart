class MantenimientoDto {
  const MantenimientoDto({
    required this.idVehiculo,
    required this.idTipoMantenimiento,
    required this.fecha,
    this.taller,
    this.kilometraje,
    this.costo,
    this.observacion,
  });
  final int idVehiculo;
  final int idTipoMantenimiento;
  final DateTime fecha;
  final String? taller;
  final int? kilometraje;
  final double? costo;
  final String? observacion;

  Map<String, dynamic> toJson() => {
    'idVehiculo': idVehiculo,
    'idTipoMantenimiento': idTipoMantenimiento,
    'fecha': fecha.toUtc().toIso8601String(),
    'taller': taller,
    'kilometraje': kilometraje,
    'costo': costo,
    'observacion': observacion,
  };
}

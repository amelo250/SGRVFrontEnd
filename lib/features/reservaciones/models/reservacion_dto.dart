class ReservacionDto {
  const ReservacionDto({
    required this.idVehiculo,
    required this.idCliente,
    required this.fechaInicio,
    required this.fechaFin,
    this.observacion,
    this.lugarEntrega,
    this.lugarRecepcion,
  });

  final int idVehiculo;
  final int idCliente;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? observacion;
  final String? lugarEntrega;
  final String? lugarRecepcion;

  Map<String, dynamic> toJson() => {
    'idVehiculo': idVehiculo,
    'idCliente': idCliente,
    'fechaInicio': fechaInicio.toUtc().toIso8601String(),
    'fechaFin': fechaFin.toUtc().toIso8601String(),
    'observacion': _nullable(observacion),
    if (lugarEntrega != null) 'lugarEntrega': lugarEntrega!.trim(),
    if (lugarRecepcion != null) 'lugarRecepcion': lugarRecepcion!.trim(),
  };

  static String? _nullable(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

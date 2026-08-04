class ReservacionDto {
  const ReservacionDto({
    required this.idVehiculo,
    required this.idCliente,
    required this.fechaInicio,
    required this.fechaFin,
    this.observacion,
  });

  final int idVehiculo;
  final int idCliente;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? observacion;

  Map<String, dynamic> toJson() => {
    'idVehiculo': idVehiculo,
    'idCliente': idCliente,
    'fechaInicio': fechaInicio.toIso8601String(),
    'fechaFin': fechaFin.toIso8601String(),
    'observacion': _nullable(observacion),
  };

  static String? _nullable(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class PagoCreateDto {
  const PagoCreateDto({
    required this.idRenta,
    required this.idMetodoPago,
    required this.idMoneda,
    required this.monto,
    required this.tasaCambioAplicada,
    required this.fechaPago,
    this.referencia,
    this.observaciones,
  });

  final int idRenta;
  final int idMetodoPago;
  final int idMoneda;
  final double monto;
  final double tasaCambioAplicada;
  final DateTime fechaPago;
  final String? referencia;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'idRenta': idRenta,
    'idMetodoPago': idMetodoPago,
    'idMoneda': idMoneda,
    'monto': monto,
    'tasaCambioAplicada': tasaCambioAplicada,
    'fechaPago': fechaPago.toUtc().toIso8601String(),
    'referencia': _nullable(referencia),
    'observaciones': _nullable(observaciones),
  };

  static String? _nullable(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

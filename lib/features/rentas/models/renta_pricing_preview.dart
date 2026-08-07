import 'dart:math' as math;

class RentaPricingPreview {
  const RentaPricingPreview({
    required this.cantidadDias,
    required this.subtotal,
    required this.total,
    required this.diferenciaTarifaDiaria,
  });

  final int cantidadDias;
  final double subtotal;
  final double total;
  final double diferenciaTarifaDiaria;

  factory RentaPricingPreview.calculate({
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required double precioPactado,
    required double precioReferencia,
    required double impuestos,
    required double descuentos,
  }) {
    final hours = fechaFin.difference(fechaInicio).inMinutes / 60;
    final days = math.max(1, (hours / 24).ceil());
    final subtotal = _round(precioPactado * days);
    final total = _round(subtotal + impuestos - descuentos);
    return RentaPricingPreview(
      cantidadDias: days,
      subtotal: subtotal,
      total: total,
      diferenciaTarifaDiaria: _round(precioReferencia - precioPactado),
    );
  }

  static double _round(double value) => (value * 100).round() / 100;
}

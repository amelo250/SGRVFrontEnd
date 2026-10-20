import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';

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
    final days = const PoliticaRentaDto(
      minimoDias: 3,
    ).dias(fechaInicio, fechaFin);
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

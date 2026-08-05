class PagoSummary {
  const PagoSummary({
    required this.idRenta,
    required this.totalRentaMonedaLocal,
    required this.totalPagadoMonedaLocal,
    required this.balancePendienteMonedaLocal,
    required this.tieneSobrepago,
    required this.montoSobrepagoMonedaLocal,
  });

  final int idRenta;
  final double totalRentaMonedaLocal;
  final double totalPagadoMonedaLocal;
  final double balancePendienteMonedaLocal;
  final bool tieneSobrepago;
  final double montoSobrepagoMonedaLocal;

  factory PagoSummary.fromJson(Map<String, dynamic> json) => PagoSummary(
    idRenta: (json['idRenta'] as num?)?.toInt() ?? 0,
    totalRentaMonedaLocal:
        (json['totalRentaMonedaLocal'] as num?)?.toDouble() ?? 0,
    totalPagadoMonedaLocal:
        (json['totalPagadoMonedaLocal'] as num?)?.toDouble() ?? 0,
    balancePendienteMonedaLocal:
        (json['balancePendienteMonedaLocal'] as num?)?.toDouble() ?? 0,
    tieneSobrepago: json['tieneSobrepago'] as bool? ?? false,
    montoSobrepagoMonedaLocal:
        (json['montoSobrepagoMonedaLocal'] as num?)?.toDouble() ?? 0,
  );
}

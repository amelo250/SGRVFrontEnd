class RentaSummary {
  const RentaSummary({
    required this.idRenta,
    required this.total,
    required this.idMoneda,
    required this.totalMonedaLocal,
    required this.totalPagadoMonedaLocal,
    required this.balancePendienteMonedaLocal,
    required this.montoSobrepagoMonedaLocal,
  });

  final int idRenta;
  final double total;
  final int idMoneda;
  final double totalMonedaLocal;
  final double totalPagadoMonedaLocal;
  final double balancePendienteMonedaLocal;
  final double montoSobrepagoMonedaLocal;

  factory RentaSummary.fromJson(Map<String, dynamic> json) => RentaSummary(
    idRenta: (json['idRenta'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toDouble() ?? 0,
    idMoneda: (json['idMoneda'] as num?)?.toInt() ?? 0,
    totalMonedaLocal: (json['totalMonedaLocal'] as num?)?.toDouble() ?? 0,
    totalPagadoMonedaLocal:
        (json['totalPagadoMonedaLocal'] as num?)?.toDouble() ?? 0,
    balancePendienteMonedaLocal:
        (json['balancePendienteMonedaLocal'] as num?)?.toDouble() ?? 0,
    montoSobrepagoMonedaLocal:
        (json['montoSobrepagoMonedaLocal'] as num?)?.toDouble() ?? 0,
  );
}

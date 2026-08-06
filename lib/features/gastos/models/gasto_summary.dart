class GastoSummary {
  const GastoSummary({
    required this.total,
    required this.mantenimiento,
    required this.operativo,
    required this.cantidad,
  });
  final double total;
  final double mantenimiento;
  final double operativo;
  final int cantidad;
  factory GastoSummary.fromJson(Map<String, dynamic> json) => GastoSummary(
    total: (json['totalMonedaLocal'] as num).toDouble(),
    mantenimiento: (json['totalMantenimiento'] as num).toDouble(),
    operativo: (json['totalOperativo'] as num).toDouble(),
    cantidad: json['cantidad'] as int,
  );
}

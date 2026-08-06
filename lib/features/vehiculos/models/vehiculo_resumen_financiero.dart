class VehiculoResumenFinanciero {
  const VehiculoResumenFinanciero({
    required this.idVehiculo,
    required this.ingresosMonedaLocal,
    required this.gastosMonedaLocal,
    required this.resultadoNeto,
    required this.cantidadRentas,
    required this.ingresoPromedioPorRenta,
    this.ultimaRenta,
    this.ultimoGasto,
  });

  final int idVehiculo;
  final double ingresosMonedaLocal;
  final double gastosMonedaLocal;
  final double resultadoNeto;
  final int cantidadRentas;
  final double ingresoPromedioPorRenta;
  final DateTime? ultimaRenta;
  final DateTime? ultimoGasto;

  factory VehiculoResumenFinanciero.fromJson(Map<String, dynamic> json) =>
      VehiculoResumenFinanciero(
        idVehiculo: (json['idVehiculo'] as num).toInt(),
        ingresosMonedaLocal: (json['ingresosMonedaLocal'] as num).toDouble(),
        gastosMonedaLocal: (json['gastosMonedaLocal'] as num).toDouble(),
        resultadoNeto: (json['resultadoNeto'] as num).toDouble(),
        cantidadRentas: (json['cantidadRentas'] as num).toInt(),
        ingresoPromedioPorRenta: (json['ingresoPromedioPorRenta'] as num)
            .toDouble(),
        ultimaRenta: _date(json['ultimaRenta']),
        ultimoGasto: _date(json['ultimoGasto']),
      );

  static DateTime? _date(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class GastoDto {
  const GastoDto({
    required this.idTipoGasto,
    required this.idMoneda,
    required this.fecha,
    required this.concepto,
    required this.monto,
    required this.tasaCambioAplicada,
    this.idVehiculo,
    this.numeroComprobante,
    this.proveedor,
    this.kilometraje,
    this.taller,
    this.observaciones,
    this.rowVersion,
  });

  final int idTipoGasto;
  final int idMoneda;
  final int? idVehiculo;
  final DateTime fecha;
  final String concepto;
  final String? numeroComprobante;
  final String? proveedor;
  final double monto;
  final double tasaCambioAplicada;
  final int? kilometraje;
  final String? taller;
  final String? observaciones;
  final String? rowVersion;

  Map<String, dynamic> toJson() => {
    'idTipoGasto': idTipoGasto,
    'idMoneda': idMoneda,
    'idVehiculo': idVehiculo,
    'fecha': fecha.toIso8601String(),
    'concepto': concepto.trim(),
    'numeroComprobante': numeroComprobante?.trim(),
    'proveedor': proveedor?.trim(),
    'monto': monto,
    'tasaCambioAplicada': tasaCambioAplicada,
    'kilometraje': kilometraje,
    'taller': taller?.trim(),
    'observaciones': observaciones?.trim(),
    if (rowVersion != null) 'rowVersion': rowVersion,
  };
}

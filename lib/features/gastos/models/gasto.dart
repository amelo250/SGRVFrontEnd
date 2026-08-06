class Gasto {
  const Gasto({
    required this.idGasto,
    required this.idTipoGasto,
    required this.tipoCodigo,
    required this.tipoNombre,
    required this.idMoneda,
    required this.monedaCodigo,
    required this.monedaSimbolo,
    required this.fecha,
    required this.concepto,
    required this.monto,
    required this.tasaCambioAplicada,
    required this.montoMonedaLocal,
    required this.activo,
    required this.rowVersion,
    this.idVehiculo,
    this.vehiculoDescripcion,
    this.numeroComprobante,
    this.proveedor,
    this.kilometraje,
    this.taller,
    this.observaciones,
  });

  final int idGasto;
  final int idTipoGasto;
  final String tipoCodigo;
  final String tipoNombre;
  final int idMoneda;
  final String monedaCodigo;
  final String monedaSimbolo;
  final int? idVehiculo;
  final String? vehiculoDescripcion;
  final DateTime fecha;
  final String concepto;
  final String? numeroComprobante;
  final String? proveedor;
  final double monto;
  final double tasaCambioAplicada;
  final double montoMonedaLocal;
  final int? kilometraje;
  final String? taller;
  final String? observaciones;
  final bool activo;
  final String rowVersion;

  factory Gasto.fromJson(Map<String, dynamic> json) => Gasto(
    idGasto: json['idGasto'] as int,
    idTipoGasto: json['idTipoGasto'] as int,
    tipoCodigo: json['tipoCodigo'] as String? ?? '',
    tipoNombre: json['tipoNombre'] as String? ?? '',
    idMoneda: json['idMoneda'] as int,
    monedaCodigo: json['monedaCodigo'] as String? ?? '',
    monedaSimbolo: json['monedaSimbolo'] as String? ?? '',
    idVehiculo: json['idVehiculo'] as int?,
    vehiculoDescripcion: json['vehiculoDescripcion'] as String?,
    fecha: DateTime.parse(json['fecha'] as String),
    concepto: json['concepto'] as String? ?? '',
    numeroComprobante: json['numeroComprobante'] as String?,
    proveedor: json['proveedor'] as String?,
    monto: (json['monto'] as num).toDouble(),
    tasaCambioAplicada: (json['tasaCambioAplicada'] as num).toDouble(),
    montoMonedaLocal: (json['montoMonedaLocal'] as num).toDouble(),
    kilometraje: json['kilometraje'] as int?,
    taller: json['taller'] as String?,
    observaciones: json['observaciones'] as String?,
    activo: json['activo'] as bool? ?? false,
    rowVersion: json['rowVersion'] as String? ?? '',
  );
}

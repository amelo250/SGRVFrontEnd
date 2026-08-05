class Pago {
  const Pago({
    required this.idPago,
    required this.idRenta,
    required this.idMetodoPago,
    required this.metodoPagoNombre,
    required this.idEstado,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.idMoneda,
    required this.codigoMoneda,
    required this.simboloMoneda,
    required this.clienteNombre,
    required this.vehiculoDescripcion,
    required this.monto,
    required this.tasaCambioAplicada,
    required this.montoMonedaLocal,
    required this.fechaPago,
    required this.activo,
    required this.fechaRegistro,
    this.referencia,
    this.observaciones,
    this.fechaActualizacion,
  });

  final int idPago;
  final int idRenta;
  final int idMetodoPago;
  final String metodoPagoNombre;
  final int idEstado;
  final String estadoCodigo;
  final String estadoNombre;
  final int idMoneda;
  final String codigoMoneda;
  final String simboloMoneda;
  final String clienteNombre;
  final String vehiculoDescripcion;
  final double monto;
  final double tasaCambioAplicada;
  final double montoMonedaLocal;
  final DateTime fechaPago;
  final String? referencia;
  final String? observaciones;
  final bool activo;
  final DateTime fechaRegistro;
  final DateTime? fechaActualizacion;

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
    idPago: _int(json['idPago']),
    idRenta: _int(json['idRenta']),
    idMetodoPago: _int(json['idMetodoPago']),
    metodoPagoNombre: json['metodoPagoNombre']?.toString() ?? '',
    idEstado: _int(json['idEstado']),
    estadoCodigo: json['estadoCodigo']?.toString() ?? '',
    estadoNombre: json['estadoNombre']?.toString() ?? '',
    idMoneda: _int(json['idMoneda']),
    codigoMoneda: json['codigoMoneda']?.toString() ?? '',
    simboloMoneda: json['simboloMoneda']?.toString() ?? '',
    clienteNombre: json['clienteNombre']?.toString() ?? '',
    vehiculoDescripcion: json['vehiculoDescripcion']?.toString() ?? '',
    monto: _double(json['monto']),
    tasaCambioAplicada: _double(json['tasaCambioAplicada']),
    montoMonedaLocal: _double(json['montoMonedaLocal']),
    fechaPago: DateTime.parse(json['fechaPago'].toString()).toLocal(),
    referencia: _text(json['referencia']),
    observaciones: _text(json['observaciones']),
    activo: json['activo'] as bool? ?? false,
    fechaRegistro: DateTime.parse(json['fechaRegistro'].toString()).toLocal(),
    fechaActualizacion: json['fechaActualizacion'] == null
        ? null
        : DateTime.tryParse(json['fechaActualizacion'].toString())?.toLocal(),
  );

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;
  static double _double(Object? value) => (value as num?)?.toDouble() ?? 0;
  static String? _text(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

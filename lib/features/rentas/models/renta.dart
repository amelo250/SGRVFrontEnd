class Renta {
  const Renta({
    required this.idRenta,
    required this.idCliente,
    required this.clienteNombre,
    required this.idVehiculo,
    required this.vehiculoDescripcion,
    required this.idEstado,
    required this.estadoCodigo,
    required this.estadoNombre,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioPorDia,
    required this.cantidadDias,
    required this.subtotal,
    required this.impuestos,
    required this.descuentos,
    required this.total,
    required this.deposito,
    required this.idMoneda,
    required this.monedaCodigo,
    required this.monedaSimbolo,
    required this.tasaCambioAplicada,
    required this.totalMonedaLocal,
    required this.fechaCreacion,
    required this.idUsuarioCreacion,
    required this.rowVersion,
    this.idReservacion,
    this.fechaEntregaReal,
    this.idProveedorVehiculo,
    this.idAcuerdoVehiculo,
    this.observaciones,
    this.fechaActualizacion,
  });

  final int idRenta;
  final int? idReservacion;
  final int idCliente;
  final String clienteNombre;
  final int idVehiculo;
  final String vehiculoDescripcion;
  final int idEstado;
  final String estadoCodigo;
  final String estadoNombre;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime? fechaEntregaReal;
  final double precioPorDia;
  final int cantidadDias;
  final double subtotal;
  final double impuestos;
  final double descuentos;
  final double total;
  final double deposito;
  final int idMoneda;
  final String monedaCodigo;
  final String monedaSimbolo;
  final double tasaCambioAplicada;
  final double totalMonedaLocal;
  final int? idProveedorVehiculo;
  final int? idAcuerdoVehiculo;
  final String? observaciones;
  final DateTime fechaCreacion;
  final DateTime? fechaActualizacion;
  final int idUsuarioCreacion;
  final String rowVersion;

  bool get activa => estadoCodigo.toUpperCase() == 'ACTIVA';
  bool get finalizada => estadoCodigo.toUpperCase() == 'FINALIZADA';
  bool get cancelada => estadoCodigo.toUpperCase() == 'CANCELADA';
  bool get puedeEditar => activa;
  bool get puedeFinalizar => activa;
  bool get puedeCancelar => activa;

  factory Renta.fromJson(Map<String, dynamic> json) => Renta(
    idRenta: _int(json['idRenta']),
    idReservacion: _nullableInt(json['idReservacion']),
    idCliente: _int(json['idCliente']),
    clienteNombre: json['clienteNombre']?.toString() ?? '',
    idVehiculo: _int(json['idVehiculo']),
    vehiculoDescripcion: json['vehiculoDescripcion']?.toString() ?? '',
    idEstado: _int(json['idEstado']),
    estadoCodigo: json['estadoCodigo']?.toString() ?? '',
    estadoNombre: json['estadoNombre']?.toString() ?? '',
    fechaInicio: _date(json['fechaInicio']),
    fechaFin: _date(json['fechaFin']),
    fechaEntregaReal: _nullableDate(json['fechaEntregaReal']),
    precioPorDia: _double(json['precioPorDia']),
    cantidadDias: _int(json['cantidadDias']),
    subtotal: _double(json['subtotal']),
    impuestos: _double(json['impuestos']),
    descuentos: _double(json['descuentos']),
    total: _double(json['total']),
    deposito: _double(json['deposito']),
    idMoneda: _int(json['idMoneda']),
    monedaCodigo: json['monedaCodigo']?.toString() ?? '',
    monedaSimbolo: json['monedaSimbolo']?.toString() ?? '',
    tasaCambioAplicada: _double(json['tasaCambioAplicada']),
    totalMonedaLocal: _double(json['totalMonedaLocal']),
    idProveedorVehiculo: _nullableInt(json['idProveedorVehiculo']),
    idAcuerdoVehiculo: _nullableInt(json['idAcuerdoVehiculo']),
    observaciones: _nullableString(json['observaciones']),
    fechaCreacion: _date(json['fechaCreacion']),
    fechaActualizacion: _nullableDate(json['fechaActualizacion']),
    idUsuarioCreacion: _int(json['idUsuarioCreacion']),
    rowVersion: json['rowVersion']?.toString() ?? '',
  );

  static int _int(Object? value) => (value as num?)?.toInt() ?? 0;
  static int? _nullableInt(Object? value) => (value as num?)?.toInt();
  static double _double(Object? value) => (value as num?)?.toDouble() ?? 0;
  static DateTime _date(Object? value) =>
      DateTime.parse(value.toString()).toLocal();
  static DateTime? _nullableDate(Object? value) =>
      value == null ? null : DateTime.tryParse(value.toString())?.toLocal();
  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}

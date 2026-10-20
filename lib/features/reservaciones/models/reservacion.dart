class Reservacion {
  const Reservacion({
    required this.idReservacion,
    required this.idVehiculo,
    required this.vehiculoDescripcion,
    required this.idCliente,
    required this.clienteNombre,
    required this.idEstado,
    required this.estadoCodigo,
    required this.estadoNombre,
    this.periodoSinHora = false,
    required this.fechaInicio,
    required this.fechaFin,
    required this.observacion,
    this.lugarEntrega,
    this.lugarRecepcion,
    required this.fechaCreacion,
  });

  final int idReservacion;
  final int idVehiculo;
  final String vehiculoDescripcion;
  final int idCliente;
  final String clienteNombre;
  final int idEstado;
  final String estadoCodigo;
  final String estadoNombre;
  final bool periodoSinHora;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String observacion;
  final String? lugarEntrega;
  final String? lugarRecepcion;
  final DateTime fechaCreacion;

  bool get puedeEditar =>
      estadoCodigo == 'PENDIENTE' || estadoCodigo == 'CONFIRMADA';
  bool get puedeConfirmar => estadoCodigo == 'PENDIENTE';
  bool get puedeCancelar =>
      estadoCodigo != 'CANCELADA' && estadoCodigo != 'CONVERTIDA';

  factory Reservacion.fromJson(Map<String, dynamic> json) => Reservacion(
    idReservacion: (json['idReservacion'] as num).toInt(),
    idVehiculo: (json['idVehiculo'] as num).toInt(),
    vehiculoDescripcion: json['vehiculoDescripcion']?.toString() ?? '',
    idCliente: (json['idCliente'] as num).toInt(),
    clienteNombre: json['clienteNombre']?.toString() ?? '',
    idEstado: (json['idEstado'] as num).toInt(),
    estadoCodigo: json['estadoCodigo']?.toString() ?? '',
    estadoNombre: json['estadoNombre']?.toString() ?? '',
    periodoSinHora: json['periodoSinHora'] == true,
    fechaInicio: DateTime.parse(json['fechaInicio'] as String).toLocal(),
    fechaFin: DateTime.parse(json['fechaFin'] as String).toLocal(),
    lugarEntrega: json['lugarEntrega']?.toString(),
    lugarRecepcion: json['lugarRecepcion']?.toString(),
    observacion: json['observacion']?.toString() ?? '',
    fechaCreacion: DateTime.parse(json['fechaCreacion'] as String).toLocal(),
  );
}

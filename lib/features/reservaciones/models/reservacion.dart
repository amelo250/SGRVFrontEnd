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
    required this.fechaInicio,
    required this.fechaFin,
    required this.observacion,
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
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String observacion;
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
    fechaInicio: DateTime.parse(json['fechaInicio'] as String).toLocal(),
    fechaFin: DateTime.parse(json['fechaFin'] as String).toLocal(),
    observacion: json['observacion']?.toString() ?? '',
    fechaCreacion: DateTime.parse(json['fechaCreacion'] as String).toLocal(),
  );
}

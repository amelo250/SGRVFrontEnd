class CalendarioEvento {
  const CalendarioEvento({
    required this.id,
    required this.tipo,
    required this.idEntidad,
    required this.idVehiculo,
    required this.vehiculo,
    required this.idCliente,
    required this.cliente,
    required this.estadoCodigo,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    this.observacion,
  });

  final String id;
  final String tipo;
  final int idEntidad;
  final int idVehiculo;
  final String vehiculo;
  final int idCliente;
  final String cliente;
  final String estadoCodigo;
  final String estado;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String? observacion;

  bool get esReservacion => tipo == 'RESERVACION';

  factory CalendarioEvento.fromJson(Map<String, dynamic> json) =>
      CalendarioEvento(
        id: json['id']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? '',
        idEntidad: (json['idEntidad'] as num).toInt(),
        idVehiculo: (json['idVehiculo'] as num).toInt(),
        vehiculo: json['vehiculo']?.toString() ?? '',
        idCliente: (json['idCliente'] as num).toInt(),
        cliente: json['cliente']?.toString() ?? '',
        estadoCodigo: json['estadoCodigo']?.toString() ?? '',
        estado: json['estado']?.toString() ?? '',
        fechaInicio: DateTime.parse(json['fechaInicio'] as String).toLocal(),
        fechaFin: DateTime.parse(json['fechaFin'] as String).toLocal(),
        observacion: json['observacion']?.toString(),
      );
}

class CalendarioResumen {
  const CalendarioResumen({
    required this.totalEventos,
    required this.totalReservaciones,
    required this.totalRentas,
    required this.eventos,
  });

  final int totalEventos;
  final int totalReservaciones;
  final int totalRentas;
  final List<CalendarioEvento> eventos;

  factory CalendarioResumen.fromJson(Map<String, dynamic> json) =>
      CalendarioResumen(
        totalEventos: (json['totalEventos'] as num?)?.toInt() ?? 0,
        totalReservaciones:
            (json['totalReservaciones'] as num?)?.toInt() ?? 0,
        totalRentas: (json['totalRentas'] as num?)?.toInt() ?? 0,
        eventos: (json['eventos'] as List<dynamic>? ?? const [])
            .map(
              (item) => CalendarioEvento.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
      );
}

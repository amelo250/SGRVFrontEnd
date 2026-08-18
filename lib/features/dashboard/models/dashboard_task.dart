class DashboardTask {
  const DashboardTask({
    required this.id,
    required this.tipo,
    required this.idEntidad,
    required this.idVehiculo,
    required this.vehiculo,
    required this.fecha,
    required this.titulo,
    required this.estadoCodigo,
    required this.esHoy,
    this.idCliente,
    this.cliente,
    this.detalle,
  });

  final String id;
  final String tipo;
  final int idEntidad;
  final int idVehiculo;
  final String vehiculo;
  final int? idCliente;
  final String? cliente;
  final DateTime fecha;
  final String titulo;
  final String? detalle;
  final String estadoCodigo;
  final bool esHoy;

  factory DashboardTask.fromJson(Map<String, dynamic> json) => DashboardTask(
    id: json['id']?.toString() ?? '',
    tipo: json['tipo']?.toString() ?? '',
    idEntidad: (json['idEntidad'] as num).toInt(),
    idVehiculo: (json['idVehiculo'] as num).toInt(),
    vehiculo: json['vehiculo']?.toString() ?? '',
    idCliente: (json['idCliente'] as num?)?.toInt(),
    cliente: json['cliente']?.toString(),
    fecha: DateTime.parse(json['fecha'] as String).toLocal(),
    titulo: json['titulo']?.toString() ?? '',
    detalle: json['detalle']?.toString(),
    estadoCodigo: json['estadoCodigo']?.toString() ?? '',
    esHoy: json['esHoy'] == true,
  );
}

class DashboardTasksResult {
  const DashboardTasksResult({
    required this.totalHoy,
    required this.totalProximas,
    required this.hoy,
    required this.proximas,
  });

  final int totalHoy;
  final int totalProximas;
  final List<DashboardTask> hoy;
  final List<DashboardTask> proximas;

  factory DashboardTasksResult.fromJson(Map<String, dynamic> json) =>
      DashboardTasksResult(
        totalHoy: (json['totalHoy'] as num?)?.toInt() ?? 0,
        totalProximas: (json['totalProximas'] as num?)?.toInt() ?? 0,
        hoy: _items(json['hoy']),
        proximas: _items(json['proximas']),
      );

  static List<DashboardTask> _items(Object? value) =>
      (value as List<dynamic>? ?? const [])
          .map((item) => DashboardTask.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
}

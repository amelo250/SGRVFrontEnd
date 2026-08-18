class DashboardSummary {
  const DashboardSummary({
    required this.empresa,
    required this.reservasHoy,
    required this.vehiculosAlquilados,
    required this.ingresosHoy,
    required this.clientesActivos,
    required this.ingresosMes,
    required this.ingresosDiarios,
    required this.reservasRecientes,
    required this.vehiculosPorCategoria,
    required this.actividadReciente,
  });
  final DashboardCompany empresa;
  final int reservasHoy, vehiculosAlquilados, clientesActivos;
  final double ingresosHoy, ingresosMes;
  final List<DashboardDailyIncome> ingresosDiarios;
  final List<DashboardRecentReservation> reservasRecientes;
  final List<DashboardVehicleCategory> vehiculosPorCategoria;
  final List<DashboardActivity> actividadReciente;
  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
    empresa: DashboardCompany.fromJson(j['empresa'] as Map<String, dynamic>),
    reservasHoy: _i(j['reservasHoy']),
    vehiculosAlquilados: _i(j['vehiculosAlquilados']),
    ingresosHoy: _d(j['ingresosHoy']),
    clientesActivos: _i(j['clientesActivos']),
    ingresosMes: _d(j['ingresosMes']),
    ingresosDiarios: _list(j['ingresosDiarios'], DashboardDailyIncome.fromJson),
    reservasRecientes: _list(
      j['reservasRecientes'],
      DashboardRecentReservation.fromJson,
    ),
    vehiculosPorCategoria: _list(
      j['vehiculosPorCategoria'],
      DashboardVehicleCategory.fromJson,
    ),
    actividadReciente: _list(
      j['actividadReciente'],
      DashboardActivity.fromJson,
    ),
  );
}

class DashboardCompany {
  const DashboardCompany({
    required this.idEmpresa,
    required this.nombre,
    required this.nombreComercial,
    this.logoUrl,
  });
  final int idEmpresa;
  final String nombre, nombreComercial;
  final String? logoUrl;
  factory DashboardCompany.fromJson(Map<String, dynamic> j) => DashboardCompany(
    idEmpresa: _i(j['idEmpresa']),
    nombre: j['nombre']?.toString() ?? '',
    nombreComercial: j['nombreComercial']?.toString() ?? '',
    logoUrl: j['logoUrl']?.toString(),
  );
}

class DashboardDailyIncome {
  const DashboardDailyIncome(this.fecha, this.monto);
  final DateTime fecha;
  final double monto;
  factory DashboardDailyIncome.fromJson(Map<String, dynamic> j) =>
      DashboardDailyIncome(
        DateTime.parse(j['fecha'].toString()).toLocal(),
        _d(j['monto']),
      );
}

class DashboardRecentReservation {
  const DashboardRecentReservation({
    required this.id,
    required this.cliente,
    required this.vehiculo,
    required this.fecha,
    required this.estado,
  });
  final int id;
  final String cliente, vehiculo, estado;
  final DateTime fecha;
  factory DashboardRecentReservation.fromJson(Map<String, dynamic> j) =>
      DashboardRecentReservation(
        id: _i(j['idReservacion']),
        cliente: j['cliente']?.toString() ?? '',
        vehiculo: j['vehiculo']?.toString() ?? '',
        fecha: DateTime.parse(j['fechaInicio'].toString()).toLocal(),
        estado: j['estadoNombre']?.toString() ?? '',
      );
}

class DashboardVehicleCategory {
  const DashboardVehicleCategory(
    this.categoria,
    this.cantidad,
    this.porcentaje,
  );
  final String categoria;
  final int cantidad;
  final double porcentaje;
  factory DashboardVehicleCategory.fromJson(Map<String, dynamic> j) =>
      DashboardVehicleCategory(
        j['categoria']?.toString() ?? '',
        _i(j['cantidad']),
        _d(j['porcentaje']),
      );
}

class DashboardActivity {
  const DashboardActivity({
    required this.tipo,
    required this.titulo,
    required this.detalle,
    required this.fecha,
  });
  final String tipo, titulo, detalle;
  final DateTime fecha;
  factory DashboardActivity.fromJson(Map<String, dynamic> j) =>
      DashboardActivity(
        tipo: j['tipo']?.toString() ?? '',
        titulo: j['titulo']?.toString() ?? '',
        detalle: j['detalle']?.toString() ?? '',
        fecha: DateTime.parse(j['fecha'].toString()).toLocal(),
      );
}

int _i(Object? x) => (x as num?)?.toInt() ?? 0;
double _d(Object? x) => (x as num?)?.toDouble() ?? 0;
List<T> _list<T>(Object? x, T Function(Map<String, dynamic>) parse) =>
    (x as List? ?? const [])
        .map((e) => parse(e as Map<String, dynamic>))
        .toList(growable: false);

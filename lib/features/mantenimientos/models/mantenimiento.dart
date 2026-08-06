class Mantenimiento {
  const Mantenimiento({
    required this.idMantenimiento,
    required this.idVehiculo,
    required this.vehiculo,
    required this.idTipoMantenimiento,
    required this.tipoCodigo,
    required this.tipoNombre,
    required this.fecha,
    this.taller,
    this.kilometraje,
    this.costo,
    this.observacion,
  });

  final int idMantenimiento;
  final int idVehiculo;
  final String vehiculo;
  final int idTipoMantenimiento;
  final String tipoCodigo;
  final String tipoNombre;
  final DateTime fecha;
  final String? taller;
  final int? kilometraje;
  final double? costo;
  final String? observacion;

  factory Mantenimiento.fromJson(Map<String, dynamic> json) => Mantenimiento(
    idMantenimiento: (json['idMantenimiento'] as num).toInt(),
    idVehiculo: (json['idVehiculo'] as num).toInt(),
    vehiculo: json['vehiculo']?.toString() ?? '',
    idTipoMantenimiento: (json['idTipoMantenimiento'] as num).toInt(),
    tipoCodigo: json['tipoCodigo']?.toString() ?? '',
    tipoNombre: json['tipoNombre']?.toString() ?? '',
    fecha: DateTime.parse(json['fecha'] as String).toLocal(),
    taller: json['taller']?.toString(),
    kilometraje: (json['kilometraje'] as num?)?.toInt(),
    costo: (json['costo'] as num?)?.toDouble(),
    observacion: json['observacion']?.toString(),
  );
}

class MantenimientoAlerta {
  const MantenimientoAlerta({
    required this.idVehiculo,
    required this.vehiculo,
    required this.kilometrajeActual,
    required this.nivel,
    required this.mensaje,
    this.ultimaFecha,
    this.ultimoKilometraje,
    this.proximaFechaEstimada,
    this.proximoKilometrajeEstimado,
  });
  final int idVehiculo;
  final String vehiculo;
  final int kilometrajeActual;
  final DateTime? ultimaFecha;
  final int? ultimoKilometraje;
  final DateTime? proximaFechaEstimada;
  final int? proximoKilometrajeEstimado;
  final String nivel;
  final String mensaje;

  factory MantenimientoAlerta.fromJson(Map<String, dynamic> json) =>
      MantenimientoAlerta(
        idVehiculo: (json['idVehiculo'] as num).toInt(),
        vehiculo: json['vehiculo']?.toString() ?? '',
        kilometrajeActual: (json['kilometrajeActual'] as num).toInt(),
        ultimaFecha: _date(json['ultimaFecha']),
        ultimoKilometraje: (json['ultimoKilometraje'] as num?)?.toInt(),
        proximaFechaEstimada: _date(json['proximaFechaEstimada']),
        proximoKilometrajeEstimado:
            (json['proximoKilometrajeEstimado'] as num?)?.toInt(),
        nivel: json['nivel']?.toString() ?? '',
        mensaje: json['mensaje']?.toString() ?? '',
      );

  static DateTime? _date(Object? value) => value == null
      ? null
      : DateTime.tryParse(value.toString())?.toLocal();
}

class MantenimientoResumen {
  const MantenimientoResumen({
    required this.totalRegistros,
    required this.costoTotal,
    required this.vehiculosSinHistorial,
    required this.alertasProximas,
    required this.alertasVencidas,
    required this.alertas,
  });
  final int totalRegistros;
  final double costoTotal;
  final int vehiculosSinHistorial;
  final int alertasProximas;
  final int alertasVencidas;
  final List<MantenimientoAlerta> alertas;

  factory MantenimientoResumen.fromJson(Map<String, dynamic> json) =>
      MantenimientoResumen(
        totalRegistros: (json['totalRegistros'] as num).toInt(),
        costoTotal: (json['costoTotal'] as num).toDouble(),
        vehiculosSinHistorial:
            (json['vehiculosSinHistorial'] as num).toInt(),
        alertasProximas: (json['alertasProximas'] as num).toInt(),
        alertasVencidas: (json['alertasVencidas'] as num).toInt(),
        alertas: (json['alertas'] as List<dynamic>? ?? const [])
            .map(
              (item) => MantenimientoAlerta.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList(growable: false),
      );
}

class MantenimientoCatalogo {
  const MantenimientoCatalogo({required this.id, required this.nombre});
  final int id;
  final String nombre;
  factory MantenimientoCatalogo.fromJson(Map<String, dynamic> json) =>
      MantenimientoCatalogo(
        id: (json['id'] as num).toInt(),
        nombre: json['nombre']?.toString() ?? '',
      );
}

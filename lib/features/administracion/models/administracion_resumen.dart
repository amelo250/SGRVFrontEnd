class AdministracionResumen {
  const AdministracionResumen({
    required this.empresasTotal,
    required this.empresasActivas,
    required this.usuariosTotal,
    required this.usuariosActivos,
    required this.catalogosConfigurables,
    required this.vehiculosTotal,
    required this.clientesTotal,
    required this.rentasTotal,
    required this.empresasRecientes,
  });

  final int empresasTotal, empresasActivas, usuariosTotal, usuariosActivos;
  final int catalogosConfigurables, vehiculosTotal, clientesTotal, rentasTotal;
  final List<AdministracionEmpresaReciente> empresasRecientes;

  factory AdministracionResumen.fromJson(
    Map<String, dynamic> json,
  ) => AdministracionResumen(
    empresasTotal: (json['empresasTotal'] as num?)?.toInt() ?? 0,
    empresasActivas: (json['empresasActivas'] as num?)?.toInt() ?? 0,
    usuariosTotal: (json['usuariosTotal'] as num?)?.toInt() ?? 0,
    usuariosActivos: (json['usuariosActivos'] as num?)?.toInt() ?? 0,
    catalogosConfigurables:
        (json['catalogosConfigurables'] as num?)?.toInt() ?? 0,
    vehiculosTotal: (json['vehiculosTotal'] as num?)?.toInt() ?? 0,
    clientesTotal: (json['clientesTotal'] as num?)?.toInt() ?? 0,
    rentasTotal: (json['rentasTotal'] as num?)?.toInt() ?? 0,
    empresasRecientes: (json['empresasRecientes'] as List<dynamic>? ?? const [])
        .map(
          (x) =>
              AdministracionEmpresaReciente.fromJson(x as Map<String, dynamic>),
        )
        .toList(growable: false),
  );
}

class AdministracionEmpresaReciente {
  const AdministracionEmpresaReciente({
    required this.idEmpresa,
    required this.nombre,
    required this.activo,
    required this.fechaRegistro,
    required this.usuarios,
  });
  final int idEmpresa, usuarios;
  final String nombre;
  final bool activo;
  final DateTime fechaRegistro;
  factory AdministracionEmpresaReciente.fromJson(Map<String, dynamic> json) =>
      AdministracionEmpresaReciente(
        idEmpresa: (json['idEmpresa'] as num?)?.toInt() ?? 0,
        nombre: json['nombre']?.toString() ?? '',
        activo: json['activo'] as bool? ?? false,
        fechaRegistro:
            DateTime.tryParse(json['fechaRegistro']?.toString() ?? '') ??
            DateTime.now(),
        usuarios: (json['usuarios'] as num?)?.toInt() ?? 0,
      );
}

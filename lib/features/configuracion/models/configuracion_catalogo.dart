class ConfiguracionCatalogoDefinition {
  const ConfiguracionCatalogoDefinition({
    required this.key,
    required this.nombre,
    this.usaCategoria = false,
    this.usaSimbolo = false,
    this.esGlobal = true,
    this.esAccesorio = false,
  });

  final String key;
  final String nombre;
  final bool usaCategoria;
  final bool usaSimbolo;
  final bool esGlobal;
  final bool esAccesorio;

  factory ConfiguracionCatalogoDefinition.fromJson(Map<String, dynamic> json) {
    return ConfiguracionCatalogoDefinition(
      key: json['key']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      usaCategoria: json['usaCategoria'] as bool? ?? false,
      usaSimbolo: json['usaSimbolo'] as bool? ?? false,
      esGlobal: json['esGlobal'] as bool? ?? true,
    );
  }
}

class ConfiguracionCatalogoItem {
  const ConfiguracionCatalogoItem({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.activo,
    this.categoria,
    this.simbolo,
    this.descripcion,
    this.icono,
    this.rowVersion,
    this.esGlobal = true,
  });

  final int id;
  final String codigo;
  final String nombre;
  final bool activo;
  final String? categoria;
  final String? simbolo;
  final String? descripcion;
  final String? icono;
  final String? rowVersion;
  final bool esGlobal;

  factory ConfiguracionCatalogoItem.fromJson(Map<String, dynamic> json) {
    return ConfiguracionCatalogoItem(
      id: (json['id'] as num).toInt(),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      categoria: json['categoria']?.toString(),
      simbolo: json['simbolo']?.toString(),
      activo: json['activo'] as bool? ?? false,
    );
  }

  factory ConfiguracionCatalogoItem.fromAccesorio(Map<String, dynamic> json) {
    return ConfiguracionCatalogoItem(
      id: (json['idAccesorio'] as num).toInt(),
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      descripcion: json['descripcion']?.toString(),
      icono: json['icono']?.toString(),
      activo: json['activo'] as bool? ?? false,
      rowVersion: json['rowVersion']?.toString(),
      esGlobal: json['esGlobal'] as bool? ?? false,
    );
  }
}

class ConfiguracionCatalogoDraft {
  const ConfiguracionCatalogoDraft({
    required this.codigo,
    required this.nombre,
    this.categoria,
    this.simbolo,
    this.descripcion,
    this.icono,
    this.rowVersion,
  });

  final String codigo;
  final String nombre;
  final String? categoria;
  final String? simbolo;
  final String? descripcion;
  final String? icono;
  final String? rowVersion;

  Map<String, dynamic> toJson({required bool accesorio}) => accesorio
      ? {
          'codigo': codigo,
          'nombre': nombre,
          'descripcion': descripcion,
          'icono': icono,
          if (rowVersion != null) 'rowVersion': rowVersion,
        }
      : {
          'codigo': codigo,
          'nombre': nombre,
          'categoria': categoria,
          'simbolo': simbolo,
        };
}

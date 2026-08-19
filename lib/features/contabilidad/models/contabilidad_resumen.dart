class ContabilidadResumen {
  const ContabilidadResumen({
    required this.ingresos,
    required this.gastos,
    required this.resultadoNeto,
    required this.margenPorcentaje,
    required this.cantidadIngresos,
    required this.cantidadGastos,
    required this.categorias,
    required this.movimientos,
  });
  final double ingresos, gastos, resultadoNeto, margenPorcentaje;
  final int cantidadIngresos, cantidadGastos;
  final List<ContabilidadCategoria> categorias;
  final List<ContabilidadMovimiento> movimientos;
  factory ContabilidadResumen.fromJson(
    Map<String, dynamic> j,
  ) => ContabilidadResumen(
    ingresos: (j['ingresos'] as num?)?.toDouble() ?? 0,
    gastos: (j['gastos'] as num?)?.toDouble() ?? 0,
    resultadoNeto: (j['resultadoNeto'] as num?)?.toDouble() ?? 0,
    margenPorcentaje: (j['margenPorcentaje'] as num?)?.toDouble() ?? 0,
    cantidadIngresos: (j['cantidadIngresos'] as num?)?.toInt() ?? 0,
    cantidadGastos: (j['cantidadGastos'] as num?)?.toInt() ?? 0,
    categorias: (j['categorias'] as List? ?? const [])
        .map((x) => ContabilidadCategoria.fromJson(x as Map<String, dynamic>))
        .toList(),
    movimientos: (j['movimientos'] as List? ?? const [])
        .map((x) => ContabilidadMovimiento.fromJson(x as Map<String, dynamic>))
        .toList(),
  );
}

class ContabilidadCategoria {
  const ContabilidadCategoria({
    required this.tipo,
    required this.codigo,
    required this.nombre,
    required this.total,
    required this.cantidad,
  });
  final String tipo, codigo, nombre;
  final double total;
  final int cantidad;
  factory ContabilidadCategoria.fromJson(Map<String, dynamic> j) =>
      ContabilidadCategoria(
        tipo: j['tipo']?.toString() ?? '',
        codigo: j['codigo']?.toString() ?? '',
        nombre: j['nombre']?.toString() ?? '',
        total: (j['total'] as num?)?.toDouble() ?? 0,
        cantidad: (j['cantidad'] as num?)?.toInt() ?? 0,
      );
}

class ContabilidadMovimiento {
  const ContabilidadMovimiento({
    required this.tipo,
    required this.categoriaCodigo,
    required this.categoriaNombre,
    required this.fecha,
    required this.concepto,
    required this.monto,
    required this.referencia,
  });
  final String tipo, categoriaCodigo, categoriaNombre, concepto, referencia;
  final DateTime fecha;
  final double monto;
  factory ContabilidadMovimiento.fromJson(Map<String, dynamic> j) =>
      ContabilidadMovimiento(
        tipo: j['tipo']?.toString() ?? '',
        categoriaCodigo: j['categoriaCodigo']?.toString() ?? '',
        categoriaNombre: j['categoriaNombre']?.toString() ?? '',
        fecha:
            DateTime.tryParse(j['fecha']?.toString() ?? '') ?? DateTime.now(),
        concepto: j['concepto']?.toString() ?? '',
        monto: (j['montoMonedaLocal'] as num?)?.toDouble() ?? 0,
        referencia: j['referencia']?.toString() ?? '',
      );
}

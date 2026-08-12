class RentaEntregaArchivo {
  const RentaEntregaArchivo({
    required this.idRenta,
    required this.nombreAgente,
    required this.nivelCombustible,
    required this.accesoriosConfirmados,
    required this.fechaFirma,
    required this.fechaGuardado,
    required this.tamanoBytes,
    required this.urlContenido,
    this.observaciones,
  });

  final int idRenta;
  final String nombreAgente;
  final int nivelCombustible;
  final String? observaciones;
  final List<int> accesoriosConfirmados;
  final DateTime fechaFirma;
  final DateTime fechaGuardado;
  final int tamanoBytes;
  final String urlContenido;

  factory RentaEntregaArchivo.fromJson(
    Map<String, dynamic> json,
  ) => RentaEntregaArchivo(
    idRenta: (json['idRenta'] as num?)?.toInt() ?? 0,
    nombreAgente: json['nombreAgente']?.toString() ?? '',
    nivelCombustible: (json['nivelCombustible'] as num?)?.toInt() ?? 0,
    observaciones: json['observaciones']?.toString(),
    accesoriosConfirmados: (json['accesoriosConfirmados'] as List? ?? const [])
        .map((value) => (value as num).toInt())
        .toList(growable: false),
    fechaFirma: DateTime.parse(json['fechaFirma'].toString()).toLocal(),
    fechaGuardado: DateTime.parse(json['fechaGuardado'].toString()).toLocal(),
    tamanoBytes: (json['tamanoBytes'] as num?)?.toInt() ?? 0,
    urlContenido: json['urlContenido']?.toString() ?? '',
  );
}

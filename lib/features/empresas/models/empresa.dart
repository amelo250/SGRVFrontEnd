class Empresa {
  const Empresa({
    required this.idEmpresa,
    required this.idPlan,
    required this.nombre,
    required this.nombreComercial,
    required this.rnc,
    required this.activo,
    this.telefono,
    this.correo,
    this.direccion,
    this.logoUrl,
  });
  final int idEmpresa, idPlan;
  final String nombre, nombreComercial, rnc;
  final String? telefono, correo, direccion, logoUrl;
  final bool activo;
  factory Empresa.fromJson(Map<String, dynamic> j) => Empresa(
    idEmpresa: (j['idEmpresa'] as num?)?.toInt() ?? 0,
    idPlan: (j['idPlan'] as num?)?.toInt() ?? 0,
    nombre: j['nombre']?.toString() ?? '',
    nombreComercial: j['nombreComercial']?.toString() ?? '',
    rnc: j['rnc']?.toString() ?? '',
    telefono: j['telefono']?.toString(),
    correo: j['correo']?.toString(),
    direccion: j['direccion']?.toString(),
    logoUrl: j['logoUrl']?.toString(),
    activo: j['activo'] as bool? ?? true,
  );
}

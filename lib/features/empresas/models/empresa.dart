class Empresa {
  final int IdEmpresa;
  final int IdPlan;
  final String nombre;
  final String? NombreComercial;
  final String? RNC;
  final String? Telefono;
  final String? Email;
  final String? Direccion;
  final String? LogoUrl;

  final bool activo;

  const Empresa({
    required this.IdEmpresa,
    required this.nombre,
    this.NombreComercial,
    this.RNC,
    this.Telefono,
    this.Email,
    this.Direccion,
    required this.IdPlan,
    this.LogoUrl,
    required this.activo,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      IdEmpresa: (json['idEmpresa'] as num).toInt(),
      IdPlan: (json['idPlan'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      RNC: json['rnc']?.toString(),
      Telefono: json['Telefono']?.toString(),
      Email: json['Email']?.toString(),
      Direccion: json['direccion']?.toString(),
      activo: json['activo'] as bool? ?? true,
    );
  }
}

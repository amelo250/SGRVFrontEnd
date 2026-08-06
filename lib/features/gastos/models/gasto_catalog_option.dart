class GastoCatalogOption {
  const GastoCatalogOption({
    required this.id,
    required this.name,
    this.code = '',
  });
  final int id;
  final String name;
  final String code;
}

class VehicleCatalogOption {
  const VehicleCatalogOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;

  factory VehicleCatalogOption.fromJson(Map<String, dynamic> json) =>
      VehicleCatalogOption(
        id: (json['id'] as num).toInt(),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class CurrencyCatalogOption extends VehicleCatalogOption {
  const CurrencyCatalogOption({
    required super.id,
    required super.code,
    required super.name,
    required this.symbol,
  });

  final String symbol;

  factory CurrencyCatalogOption.fromJson(Map<String, dynamic> json) =>
      CurrencyCatalogOption(
        id: (json['id'] as num).toInt(),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
      );
}

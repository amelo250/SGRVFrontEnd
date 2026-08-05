class PagoCatalogOption {
  const PagoCatalogOption({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;

  factory PagoCatalogOption.fromJson(Map<String, dynamic> json) =>
      PagoCatalogOption(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
}

class PagoCurrencyOption extends PagoCatalogOption {
  const PagoCurrencyOption({
    required super.id,
    required super.code,
    required super.name,
    required this.symbol,
  });

  final String symbol;

  factory PagoCurrencyOption.fromJson(Map<String, dynamic> json) =>
      PagoCurrencyOption(
        id: (json['id'] as num?)?.toInt() ?? 0,
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        symbol: json['symbol']?.toString() ?? '',
      );
}

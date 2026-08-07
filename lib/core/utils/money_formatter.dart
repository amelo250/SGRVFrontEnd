import 'package:intl/intl.dart';

class MoneyFormatter {
  MoneyFormatter._();

  static final NumberFormat _amount = NumberFormat('#,##0.00', 'es_DO');

  static String format(
    num value, {
    required String currencyCode,
    required String currencySymbol,
  }) {
    final prefix = displaySymbol(currencyCode, currencySymbol);
    return prefix.isEmpty
        ? '${_amount.format(value)} ${currencyCode.toUpperCase()}'.trim()
        : '$prefix ${_amount.format(value)}';
  }

  static String displaySymbol(String code, String symbol) {
    switch (code.trim().toUpperCase()) {
      case 'DOP':
        return r'RD$';
      case 'USD':
        return r'US$';
      default:
        return symbol.trim().isNotEmpty ? symbol.trim() : code.toUpperCase();
    }
  }

  static bool isLocal(String currencyCode) =>
      currencyCode.trim().toUpperCase() == 'DOP';

  static double toLocal(num amount, num exchangeRate) =>
      (amount * exchangeRate * 100).round() / 100;
}

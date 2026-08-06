import 'gasto.dart';

class GastoPageResult {
  const GastoPageResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<Gasto> items;
  final int total;
  final int page;
  final int pageSize;
  int get totalPages => total == 0 ? 1 : (total / pageSize).ceil();
}

import 'package:sgrv_frontend/features/pagos/models/pago.dart';

class PagoPageResult {
  const PagoPageResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<Pago> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  int get totalPages =>
      totalCount == 0 ? 1 : (totalCount + pageSize - 1) ~/ pageSize;
}

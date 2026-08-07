import 'package:sgrv_frontend/features/rentas/models/renta.dart';

class RentaPageResult {
  const RentaPageResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<Renta> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  int get totalPages =>
      totalCount == 0 ? 1 : ((totalCount + pageSize - 1) ~/ pageSize);
}

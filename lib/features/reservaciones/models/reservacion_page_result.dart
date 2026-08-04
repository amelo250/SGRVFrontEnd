import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';

class ReservacionPageResult {
  const ReservacionPageResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<Reservacion> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  int get totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
}

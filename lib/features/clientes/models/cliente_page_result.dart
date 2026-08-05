import 'package:sgrv_frontend/features/clientes/models/cliente.dart';

class ClientePageResult {
  const ClientePageResult({
    required this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<Cliente> items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;

  int get totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
}

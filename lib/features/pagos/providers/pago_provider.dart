import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/pagos/models/pago.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_dto.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_summary.dart';
import 'package:sgrv_frontend/features/pagos/services/pago_service.dart';

enum PagoStatus { initial, loading, success, empty, error }

class PagoProvider extends ChangeNotifier {
  PagoProvider({PagoService? service}) : _service = service ?? PagoService();

  final PagoService _service;
  List<Pago> _items = const [];
  PagoStatus _status = PagoStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  String _search = '';
  int _pageNumber = 1;
  int _pageSize = 20;
  int _totalCount = 0;
  int _totalPages = 1;
  int _requestVersion = 0;
  Pago? _selected;
  PagoSummary? _summary;

  List<Pago> get items => List.unmodifiable(_items);
  PagoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < _totalPages;
  Pago? get selected => _selected;
  PagoSummary? get summary => _summary;

  Future<void> load({bool refresh = false, int? idRenta}) async {
    final version = ++_requestVersion;
    if (!refresh) _status = PagoStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _service.getAll(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        search: _search,
        idRenta: idRenta,
      );
      if (version != _requestVersion) return;
      _items = page.items;
      _pageNumber = page.pageNumber;
      _pageSize = page.pageSize;
      _totalCount = page.totalCount;
      _totalPages = page.totalPages;
      _status = _items.isEmpty ? PagoStatus.empty : PagoStatus.success;
    } on ApiException catch (error) {
      if (version != _requestVersion) return;
      _errorMessage = error.message;
      _status = PagoStatus.error;
    } catch (_) {
      if (version != _requestVersion) return;
      _errorMessage = 'No fue posible cargar los pagos.';
      _status = PagoStatus.error;
    }
    if (version == _requestVersion) notifyListeners();
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _pageNumber = 1;
    await load();
  }

  Future<void> previousPage() async {
    if (!hasPreviousPage) return;
    _pageNumber--;
    await load();
  }

  Future<void> nextPage() async {
    if (!hasNextPage) return;
    _pageNumber++;
    await load();
  }

  Future<bool> loadDetail(int id) async {
    _errorMessage = null;
    notifyListeners();
    try {
      _selected = await _service.getById(id);
      _summary = await _service.getSummary(_selected!.idRenta);
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible cargar el detalle del pago.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> create(PagoCreateDto dto) => _mutate(() => _service.create(dto));

  Future<bool> voidPayment(int id) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.voidPayment(id);
      await load(refresh: true);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible anular el pago.';
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  Future<bool> restore(int id) =>
      _mutate(() => _service.restore(id), detailId: id);

  Future<bool> _mutate(
    Future<Pago> Function() operation, {
    int? detailId,
  }) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _selected = await operation();
      await load(refresh: true);
      if (detailId != null) await loadDetail(detailId);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible completar la operación.';
      return false;
    } finally {
      _isMutating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

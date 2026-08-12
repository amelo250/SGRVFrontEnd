import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_summary.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_filters.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_service.dart';

enum RentaStatus { initial, loading, success, empty, error }

class RentaProvider extends ChangeNotifier {
  RentaProvider({RentaService? service}) : _service = service ?? RentaService();

  final RentaService _service;
  List<Renta> _items = const [];
  RentaStatus _status = RentaStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  String _search = '';
  int _pageNumber = 1;
  int _pageSize = 20;
  int _totalCount = 0;
  int _totalPages = 1;
  int _requestVersion = 0;
  Renta? _selected;
  RentaSummary? _summary;
  RentaEntrega? _entrega;
  bool _loadingEntrega = false;
  RentaListScope _scope = RentaListScope.active;
  RentaFilters _filters = const RentaFilters();

  List<Renta> get items => List.unmodifiable(_items);
  RentaStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < _totalPages;
  Renta? get selected => _selected;
  RentaSummary? get summary => _summary;
  RentaEntrega? get entrega => _entrega;
  bool get loadingEntrega => _loadingEntrega;
  RentaListScope get scope => _scope;
  RentaFilters get filters => _filters;

  Future<bool> loadEntrega(int id) async {
    _loadingEntrega = true;
    _entrega = null;
    _errorMessage = null;
    notifyListeners();
    try {
      _entrega = await _service.getEntrega(id);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible preparar el formulario de entrega.';
      return false;
    } finally {
      _loadingEntrega = false;
      notifyListeners();
    }
  }

  Future<void> load({bool refresh = false}) async {
    final version = ++_requestVersion;
    if (!refresh) _status = RentaStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _service.getAll(
        scope: _scope,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        search: _search,
        fechaDesde: _filters.fechaDesde,
        fechaHasta: _filters.fechaHasta,
      );
      if (version != _requestVersion) return;
      _items = page.items;
      _pageNumber = page.pageNumber;
      _pageSize = page.pageSize;
      _totalCount = page.totalCount;
      _totalPages = page.totalPages;
      _status = _items.isEmpty ? RentaStatus.empty : RentaStatus.success;
    } on ApiException catch (error) {
      if (version != _requestVersion) return;
      _errorMessage = error.message;
      _status = RentaStatus.error;
    } catch (_) {
      if (version != _requestVersion) return;
      _errorMessage = 'No fue posible cargar las rentas.';
      _status = RentaStatus.error;
    }
    if (version == _requestVersion) notifyListeners();
  }

  Future<void> changeScope(RentaListScope value) async {
    if (_scope == value && _status != RentaStatus.initial) return;
    _scope = value;
    _pageNumber = 1;
    await load();
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _pageNumber = 1;
    await load();
  }

  Future<void> applyDateRange(DateTime? from, DateTime? to) async {
    _filters = RentaFilters(fechaDesde: from, fechaHasta: to);
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
      final results = await Future.wait<Object>([
        _service.getById(id),
        _service.getSummary(id),
      ]);
      _selected = results[0] as Renta;
      _summary = results[1] as RentaSummary;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible cargar el detalle de la renta.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> create(RentaCreateDto dto) =>
      _mutate(() => _service.create(dto));

  Future<bool> createFromReservation(
    int reservationId,
    ConvertirReservacionRentaDto dto,
  ) => _mutate(() => _service.createFromReservation(reservationId, dto));

  Future<bool> update(int id, RentaUpdateDto dto) =>
      _mutate(() => _service.update(id, dto), detailId: id);

  Future<bool> complete(int id, FinalizarRentaDto dto) =>
      _mutate(() => _service.complete(id, dto), detailId: id);

  Future<bool> cancel(int id) =>
      _mutate(() => _service.cancel(id), detailId: id);

  Future<bool> _mutate(
    Future<Renta> Function() operation, {
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

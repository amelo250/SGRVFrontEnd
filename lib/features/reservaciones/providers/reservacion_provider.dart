import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_dto.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_page_result.dart';
import 'package:sgrv_frontend/features/reservaciones/services/reservacion_service.dart';

enum ReservacionStatus { initial, loading, success, empty, error }

class ReservacionProvider extends ChangeNotifier {
  ReservacionProvider({ReservacionService? service})
    : _service = service ?? ReservacionService();

  final ReservacionService _service;
  List<Reservacion> _items = const [];
  ReservacionStatus _status = ReservacionStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  String _search = '';
  int _pageNumber = 1;
  int _pageSize = 20;
  int _totalCount = 0;
  int _totalPages = 1;
  int _requestVersion = 0;
  List<Reservacion> _recent = const [];
  List<Reservacion> _upcoming = const [];

  List<Reservacion> get items => List.unmodifiable(_items);
  ReservacionStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < _totalPages;
  List<Reservacion> get recent => List.unmodifiable(_recent);
  List<Reservacion> get upcoming => List.unmodifiable(_upcoming);

  Future<void> load({bool refresh = false}) async {
    final requestVersion = ++_requestVersion;
    if (!refresh) _status = ReservacionStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _service.getAll(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        search: _search,
      );
      if (requestVersion != _requestVersion) return;
      _items = page.items;
      _pageNumber = page.pageNumber;
      _pageSize = page.pageSize;
      _totalCount = page.totalCount;
      _totalPages = page.totalPages;
      _status = _items.isEmpty
          ? ReservacionStatus.empty
          : ReservacionStatus.success;
    } on ApiException catch (error) {
      if (requestVersion != _requestVersion) return;
      _errorMessage = error.message;
      _status = ReservacionStatus.error;
    } catch (_) {
      if (requestVersion != _requestVersion) return;
      _errorMessage = 'No fue posible cargar las reservaciones.';
      _status = ReservacionStatus.error;
    }
    if (requestVersion == _requestVersion) notifyListeners();
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _pageNumber = 1;
    await load();
  }

  Future<void> loadDashboard() async {
    try {
      final results = await Future.wait<Object>([
        _service.getAll(pageNumber: 1, pageSize: 4),
        _service.getUpcoming(take: 3),
      ]);
      _recent = (results[0] as ReservacionPageResult).items;
      _upcoming = results[1] as List<Reservacion>;
      notifyListeners();
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
    }
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

  Future<bool> create(ReservacionDto dto) =>
      _mutate(() => _service.create(dto));
  Future<bool> update(int id, ReservacionDto dto) =>
      _mutate(() => _service.update(id, dto));
  Future<bool> confirm(int id) => _mutate(() => _service.confirm(id));
  Future<bool> cancel(int id) => _mutate(() => _service.cancel(id));

  Future<bool> _mutate(Future<Object?> Function() operation) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
      await load(refresh: true);
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'No fue posible guardar los cambios.';
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

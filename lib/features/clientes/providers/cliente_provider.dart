import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente_dto.dart';
import 'package:sgrv_frontend/features/clientes/services/cliente_service.dart';

enum ClienteStatus { initial, loading, success, empty, error }

class ClienteProvider extends ChangeNotifier {
  ClienteProvider({ClienteService? service})
    : _service = service ?? ClienteService();

  final ClienteService _service;
  List<Cliente> _clientes = const [];
  ClienteStatus _status = ClienteStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  bool _incluirInactivos = false;
  String _search = '';
  int _pageNumber = 1;
  int _pageSize = 20;
  int _totalCount = 0;
  int _totalPages = 1;

  List<Cliente> get clientes => List.unmodifiable(_clientes);
  ClienteStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  bool get incluirInactivos => _incluirInactivos;
  int get pageNumber => _pageNumber;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  bool get hasPreviousPage => _pageNumber > 1;
  bool get hasNextPage => _pageNumber < _totalPages;

  Future<void> cargar({bool refresh = false}) async {
    if (!refresh) _status = ClienteStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _service.getClientes(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        search: _search,
        incluirInactivos: _incluirInactivos,
      );
      _clientes = page.items;
      _pageNumber = page.pageNumber;
      _pageSize = page.pageSize;
      _totalCount = page.totalCount;
      _totalPages = page.totalPages;
      _status = _clientes.isEmpty
          ? ClienteStatus.empty
          : ClienteStatus.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _status = ClienteStatus.error;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los clientes.';
      _status = ClienteStatus.error;
    }
    notifyListeners();
  }

  Future<void> buscar(String value) async {
    _search = value.trim();
    _pageNumber = 1;
    await cargar();
  }

  Future<void> establecerIncluirInactivos(bool value) async {
    _incluirInactivos = value;
    _pageNumber = 1;
    await cargar();
  }

  Future<void> paginaAnterior() async {
    if (!hasPreviousPage) return;
    _pageNumber--;
    await cargar();
  }

  Future<void> paginaSiguiente() async {
    if (!hasNextPage) return;
    _pageNumber++;
    await cargar();
  }

  Future<bool> crear(ClienteDto dto) =>
      _mutar(() => _service.crear(dto));
  Future<bool> actualizar(int id, ClienteDto dto) =>
      _mutar(() => _service.actualizar(id, dto));
  Future<bool> desactivar(int id) => _mutar(() async {
    await _service.desactivar(id);
    return null;
  });
  Future<bool> restaurar(int id) =>
      _mutar(() => _service.restaurar(id));

  Future<bool> _mutar(Future<Object?> Function() operation) async {
    _isMutating = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await operation();
      await cargar(refresh: true);
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
}

import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import '../models/gasto.dart';
import '../models/gasto_catalog_option.dart';
import '../models/gasto_dto.dart';
import '../models/gasto_summary.dart';
import '../services/gasto_service.dart';

enum GastoStatus { initial, loading, success, empty, error }

class GastoProvider extends ChangeNotifier {
  GastoProvider({GastoService? service}) : _service = service ?? GastoService();
  final GastoService _service;
  List<Gasto> _items = const [];
  GastoStatus _status = GastoStatus.initial;
  String? _error;
  bool _saving = false;
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  String _search = '';
  GastoSummary? _summary;
  List<GastoCatalogOption> _tipos = const [];
  List<GastoCatalogOption> _monedas = const [];
  List<GastoCatalogOption> _vehiculos = const [];

  List<Gasto> get items => List.unmodifiable(_items);
  GastoStatus get status => _status;
  String? get error => _error;
  bool get saving => _saving;
  int get page => _page;
  int get totalPages => _totalPages;
  int get total => _total;
  GastoSummary? get summaryData => _summary;
  List<GastoCatalogOption> get tipos => _tipos;
  List<GastoCatalogOption> get monedas => _monedas;
  List<GastoCatalogOption> get vehiculos => _vehiculos;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) _status = GastoStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.getAll(page: _page, search: _search);
      _items = result.items;
      _total = result.total;
      _totalPages = result.totalPages;
      _summary = await _service.summary();
      _status = _items.isEmpty ? GastoStatus.empty : GastoStatus.success;
    } on ApiException catch (e) {
      _error = e.message;
      _status = GastoStatus.error;
    } catch (_) {
      _error = 'No fue posible cargar los gastos.';
      _status = GastoStatus.error;
    }
    notifyListeners();
  }

  Future<void> search(String value) async {
    _search = value.trim();
    _page = 1;
    await load();
  }

  Future<void> nextPage() async {
    if (_page < _totalPages) {
      _page++;
      await load();
    }
  }

  Future<void> previousPage() async {
    if (_page > 1) {
      _page--;
      await load();
    }
  }

  Future<bool> loadCatalogs() async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      final values = await Future.wait([
        _service.tipos(),
        _service.monedas(),
        _service.vehiculos(),
      ]);
      _tipos = values[0];
      _monedas = values[1];
      _vehiculos = values[2];
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No fue posible cargar los catálogos.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  String? validate(GastoDto dto) {
    if (dto.idTipoGasto <= 0) return 'Selecciona el tipo de gasto.';
    if (dto.idMoneda <= 0) return 'Selecciona la moneda.';
    if (dto.concepto.trim().isEmpty) return 'Escribe el concepto.';
    if (dto.monto <= 0) return 'El monto debe ser mayor que cero.';
    if (dto.tasaCambioAplicada <= 0) return 'La tasa debe ser mayor que cero.';
    return null;
  }

  Future<bool> save(GastoDto dto, {int? id}) async {
    final validation = validate(dto);
    if (validation != null) {
      _error = validation;
      notifyListeners();
      return false;
    }
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      if (id == null) {
        await _service.create(dto);
      } else {
        await _service.update(id, dto);
      }
      await load(refresh: true);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No fue posible guardar el gasto.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(int id) async {
    _saving = true;
    _error = null;
    notifyListeners();
    try {
      await _service.delete(id);
      await load(refresh: true);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'No fue posible eliminar el gasto.';
      return false;
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

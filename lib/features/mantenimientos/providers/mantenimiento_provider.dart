import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento_dto.dart';
import 'package:sgrv_frontend/features/mantenimientos/services/mantenimiento_service.dart';

enum MantenimientoStatus { initial, loading, success, empty, error }

class MantenimientoProvider extends ChangeNotifier {
  MantenimientoProvider({MantenimientoService? service})
    : _service = service ?? MantenimientoService();
  final MantenimientoService _service;
  List<Mantenimiento> _items = const [];
  List<MantenimientoCatalogo> _tipos = const [];
  List<MantenimientoCatalogo> _vehiculos = const [];
  MantenimientoResumen? _resumen;
  MantenimientoStatus _status = MantenimientoStatus.initial;
  String? _error;
  bool _saving = false;

  List<Mantenimiento> get items => List.unmodifiable(_items);
  List<MantenimientoCatalogo> get tipos => List.unmodifiable(_tipos);
  List<MantenimientoCatalogo> get vehiculos => List.unmodifiable(_vehiculos);
  MantenimientoResumen? get resumen => _resumen;
  MantenimientoStatus get status => _status;
  String? get error => _error;
  bool get saving => _saving;

  Future<void> load({String? search, bool refresh = false}) async {
    if (!refresh) _status = MantenimientoStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await Future.wait<Object>([
        _service.getAll(search: search),
        _service.resumen(),
      ]);
      _items = result[0] as List<Mantenimiento>;
      _resumen = result[1] as MantenimientoResumen;
      _status = _items.isEmpty
          ? MantenimientoStatus.empty
          : MantenimientoStatus.success;
    } on ApiException catch (error) {
      _error = error.message;
      _status = MantenimientoStatus.error;
    } catch (_) {
      _error = 'No fue posible cargar los mantenimientos.';
      _status = MantenimientoStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadCatalogs() async {
    final result = await Future.wait([
      _service.tipos(),
      _service.vehiculos(),
    ]);
    _tipos = result[0];
    _vehiculos = result[1];
    notifyListeners();
  }

  Future<bool> save(MantenimientoDto dto, {int? id}) async {
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
    } on ApiException catch (error) {
      _error = error.message;
      return false;
    } catch (_) {
      _error = 'No fue posible guardar el mantenimiento.';
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

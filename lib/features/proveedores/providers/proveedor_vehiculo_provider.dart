import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo_dto.dart';
import 'package:sgrv_frontend/features/proveedores/services/proveedor_vehiculo_service.dart';

enum ProveedorStatus { initial, loading, success, empty, error }

class ProveedorVehiculoProvider extends ChangeNotifier {
  ProveedorVehiculoProvider({ProveedorVehiculoService? service})
    : _service = service ?? ProveedorVehiculoService();

  final ProveedorVehiculoService _service;
  List<ProveedorVehiculo> _proveedores = const [];
  ProveedorStatus _status = ProveedorStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  bool _incluirInactivos = false;

  List<ProveedorVehiculo> get proveedores => List.unmodifiable(_proveedores);
  ProveedorStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  bool get incluirInactivos => _incluirInactivos;

  Future<void> cargar({String? busqueda, bool refresh = false}) async {
    if (!refresh) _status = ProveedorStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _proveedores = await _service.obtenerTodos(
        incluirInactivos: _incluirInactivos,
        busqueda: busqueda,
      );
      _status = _proveedores.isEmpty
          ? ProveedorStatus.empty
          : ProveedorStatus.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _status = ProveedorStatus.error;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los proveedores.';
      _status = ProveedorStatus.error;
    }
    notifyListeners();
  }

  Future<void> establecerIncluirInactivos(bool value) async {
    _incluirInactivos = value;
    await cargar();
  }

  Future<bool> crear(ProveedorVehiculoDto dto) =>
      _mutar(() => _service.crear(dto));

  Future<bool> actualizar(int id, ProveedorVehiculoDto dto) =>
      _mutar(() => _service.actualizar(id, dto));

  Future<bool> desactivar(int id) => _mutar(() async {
    await _service.desactivar(id);
    return null;
  });

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

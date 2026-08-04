import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_dto.dart';
import 'package:sgrv_frontend/features/vehiculos/services/vehiculo_service.dart';

enum VehiculoStatus { initial, loading, success, empty, error }

class VehiculoProvider extends ChangeNotifier {
  VehiculoProvider({VehiculoService? service})
    : _service = service ?? VehiculoService();

  final VehiculoService _service;
  List<Vehiculo> _vehiculos = const [];
  VehiculoStatus _status = VehiculoStatus.initial;
  String? _errorMessage;
  bool _isMutating = false;
  bool _incluirInactivos = false;

  List<Vehiculo> get vehiculos => List.unmodifiable(_vehiculos);
  VehiculoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  bool get incluirInactivos => _incluirInactivos;

  Future<void> cargar({bool refresh = false}) async {
    if (!refresh) _status = VehiculoStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehiculos = await _service.getVehiculos(
        incluirInactivos: _incluirInactivos,
      );
      _status = _vehiculos.isEmpty
          ? VehiculoStatus.empty
          : VehiculoStatus.success;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      _status = VehiculoStatus.error;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los vehículos.';
      _status = VehiculoStatus.error;
    }

    notifyListeners();
  }

  Future<void> establecerIncluirInactivos(bool value) async {
    _incluirInactivos = value;
    await cargar();
  }

  Future<bool> crear(VehiculoDto dto) => _mutar(() => _service.crear(dto));

  Future<bool> actualizar(int id, VehiculoDto dto) =>
      _mutar(() => _service.actualizar(id, dto));

  Future<bool> cambiarEstado(int id, int idEstado) =>
      _mutar(() => _service.cambiarEstado(id, idEstado));

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

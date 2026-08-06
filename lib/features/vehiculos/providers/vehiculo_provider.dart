import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_dto.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_resumen_financiero.dart';
import 'package:sgrv_frontend/features/vehiculos/services/vehiculo_service.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_filter.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';

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
  VehiculoResumenFinanciero? _resumenFinanciero;
  bool _isLoadingSummary = false;
  String? _summaryError;
  VehiculoFilter _filter = const VehiculoFilter();
  List<String> _marcas = const [];
  Map<String, String>? _imageHeaders;

  List<Vehiculo> get vehiculos => List.unmodifiable(_vehiculos);
  VehiculoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isMutating => _isMutating;
  bool get incluirInactivos => _incluirInactivos;
  VehiculoResumenFinanciero? get resumenFinanciero => _resumenFinanciero;
  bool get isLoadingSummary => _isLoadingSummary;
  String? get summaryError => _summaryError;
  VehiculoFilter get filter => _filter;
  List<String> get marcas => List.unmodifiable(_marcas);
  Map<String, String>? get imageHeaders => _imageHeaders;
  bool get tieneFiltros => !_filter.isEmpty;

  Future<void> cargar({bool refresh = false}) async {
    if (!refresh) _status = VehiculoStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<Object>([
        _service.getVehiculos(
          incluirInactivos: _incluirInactivos,
          filter: _filter,
        ),
        if (_marcas.isEmpty) _service.getMarcas(),
      ]);
      _vehiculos = results.first as List<Vehiculo>;
      if (_marcas.isEmpty && results.length > 1) {
        _marcas = results[1] as List<String>;
      }
      final token = await TokenStorage.getToken();
      _imageHeaders = token == null || token.isEmpty
          ? null
          : {'Authorization': 'Bearer $token'};
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

  Future<void> establecerTipo(int? value) async {
    _filter = _filter.copyWith(idTipo: value, clearTipo: value == null);
    await cargar();
  }

  Future<void> establecerCombustible(int? value) async {
    _filter = _filter.copyWith(
      idCombustible: value,
      clearCombustible: value == null,
    );
    await cargar();
  }

  Future<void> establecerMarca(String? value) async {
    _filter = _filter.copyWith(marca: value, clearMarca: value == null);
    await cargar();
  }

  Future<void> limpiarFiltros() async {
    _filter = const VehiculoFilter();
    await cargar();
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

  Future<void> cargarResumenFinanciero(int idVehiculo) async {
    _isLoadingSummary = true;
    _summaryError = null;
    _resumenFinanciero = null;
    notifyListeners();
    try {
      _resumenFinanciero = await _service.obtenerResumenFinanciero(idVehiculo);
    } on ApiException catch (error) {
      _summaryError = error.message;
    } catch (_) {
      _summaryError = 'No fue posible cargar el resumen financiero.';
    } finally {
      _isLoadingSummary = false;
      notifyListeners();
    }
  }

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

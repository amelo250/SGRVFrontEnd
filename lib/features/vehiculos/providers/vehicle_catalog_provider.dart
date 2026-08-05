import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehicle_catalog_option.dart';
import 'package:sgrv_frontend/features/vehiculos/services/vehicle_catalog_service.dart';

class VehicleCatalogProvider extends ChangeNotifier {
  VehicleCatalogProvider({VehicleCatalogService? service})
    : _service = service ?? VehicleCatalogService();

  final VehicleCatalogService _service;
  bool _loading = false;
  bool _loaded = false;
  String? _errorMessage;
  List<VehicleCatalogOption> _types = const [];
  List<VehicleCatalogOption> _fuels = const [];
  List<VehicleCatalogOption> _transmissions = const [];
  List<CurrencyCatalogOption> _currencies = const [];

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<VehicleCatalogOption> get types => List.unmodifiable(_types);
  List<VehicleCatalogOption> get fuels => List.unmodifiable(_fuels);
  List<VehicleCatalogOption> get transmissions =>
      List.unmodifiable(_transmissions);
  List<CurrencyCatalogOption> get currencies => List.unmodifiable(_currencies);

  Future<void> load({bool force = false}) async {
    if (_loading || (_loaded && !force)) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _service.getTypes(),
        _service.getFuels(),
        _service.getTransmissions(),
        _service.getCurrencies(),
      ]);
      _types = results[0] as List<VehicleCatalogOption>;
      _fuels = results[1] as List<VehicleCatalogOption>;
      _transmissions = results[2] as List<VehicleCatalogOption>;
      _currencies = results[3] as List<CurrencyCatalogOption>;
      if (_types.isEmpty) {
        throw const ApiException(
          message:
              'No existen tipos de vehículo activos en la categoría VEHICULOS.',
        );
      }
      _loaded = true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los catálogos del vehículo.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

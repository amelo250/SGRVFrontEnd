import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_catalog_option.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_summary.dart';
import 'package:sgrv_frontend/features/pagos/services/pago_catalog_service.dart';
import 'package:sgrv_frontend/features/pagos/services/pago_service.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_page_result.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_service.dart';

class PagoFormProvider extends ChangeNotifier {
  PagoFormProvider({
    PagoCatalogService? catalogService,
    RentaService? rentaService,
    PagoService? pagoService,
  }) : _catalogService = catalogService ?? PagoCatalogService(),
       _rentaService = rentaService ?? RentaService(),
       _pagoService = pagoService ?? PagoService();

  final PagoCatalogService _catalogService;
  final RentaService _rentaService;
  final PagoService _pagoService;
  List<Renta> _rentas = const [];
  List<PagoCatalogOption> _methods = const [];
  List<PagoCurrencyOption> _currencies = const [];
  PagoSummary? _summary;
  bool _loading = false;
  String? _errorMessage;

  List<Renta> get rentas => List.unmodifiable(_rentas);
  List<PagoCatalogOption> get methods => List.unmodifiable(_methods);
  List<PagoCurrencyOption> get currencies => List.unmodifiable(_currencies);
  PagoSummary? get summary => _summary;
  bool get loading => _loading;
  String? get errorMessage => _errorMessage;

  Future<void> load({int? preferredRentalId}) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        _rentaService.getAll(pageSize: 100),
        _catalogService.getPaymentMethods(),
        _catalogService.getCurrencies(),
      ]);
      _rentas = (results[0] as RentaPageResult).items
          .where((item) => item.activa)
          .toList(growable: false);
      _methods = results[1] as List<PagoCatalogOption>;
      _currencies = results[2] as List<PagoCurrencyOption>;
      if (preferredRentalId != null)
        await selectRental(preferredRentalId, notify: false);
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'No fue posible cargar los datos del formulario.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> selectRental(int id, {bool notify = true}) async {
    _summary = null;
    if (notify) notifyListeners();
    try {
      _summary = await _pagoService.getSummary(id);
      _errorMessage = null;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    }
    if (notify) notifyListeners();
  }

  double localAmount({
    required double amount,
    required String currencyCode,
    required double rate,
  }) => amount * (currencyCode.toUpperCase() == 'DOP' ? 1 : rate);

  String? validate({required double amount, required double localAmount}) {
    if (amount <= 0) return 'El monto debe ser mayor que cero.';
    if (_summary != null &&
        localAmount > _summary!.balancePendienteMonedaLocal + 0.005) {
      return 'El pago excede el balance pendiente.';
    }
    return null;
  }

  @override
  void dispose() {
    _catalogService.dispose();
    _rentaService.dispose();
    _pagoService.dispose();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';

class EmpresaProvider extends ChangeNotifier {
  final EmpresaService _empresaService;

  EmpresaProvider({EmpresaService? empresaService})
    : _empresaService = empresaService ?? EmpresaService();

  bool _isLoading = false;
  String? _errorMessage;
  List<Empresa> _empresas = [];

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Empresa> get empresas => List.unmodifiable(_empresas);
  Empresa? _actual;
  Empresa? get actual => _actual;

  Future<void> cargarEmpresas() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _empresas = await _empresaService.getEmpresas();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> cargarActual() async {
    try {
      _actual = await _empresaService.getCurrent();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> onboarding({
    required List<int> logo,
    required String fileName,
    required String contentType,
    required String nombre,
    required String nombreComercial,
    required String rnc,
    required int idPlan,
    String? telefono,
    String? correo,
    String? direccion,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final created = await _empresaService.onboarding(
        logo: logo,
        fileName: fileName,
        contentType: contentType,
        nombre: nombre,
        nombreComercial: nombreComercial,
        rnc: rnc,
        idPlan: idPlan,
        telefono: telefono,
        correo: correo,
        direccion: direccion,
      );
      _empresas = [created, ..._empresas];
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _empresaService.dispose();
    super.dispose();
  }
}

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
}

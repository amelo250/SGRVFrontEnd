import 'package:sgrv_frontend/core/session/session_state.dart';
import '../models/administracion_resumen.dart';
import '../services/administracion_service.dart';

class AdministracionProvider extends SessionNotifier {
  AdministracionProvider({AdministracionService? service})
    : _service = service ?? AdministracionService();
  final AdministracionService _service;
  AdministracionResumen? resumen;
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      resumen = await _service.getResumen();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

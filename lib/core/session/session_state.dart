import 'package:flutter/foundation.dart';

/// Cada cambio de identidad invalida el árbol y sus solicitudes pendientes.
class SessionState {
  static final generation = ValueNotifier<int>(0);
  static void changed() => generation.value++;
  static void requireCurrent(int expected) {
    if (generation.value != expected) {
      throw StateError('La sesión cambió. Se descartó la respuesta anterior.');
    }
  }
}

/// Las solicitudes que terminan tras desmontar una sesión no notifican su UI.
class SessionNotifier extends ChangeNotifier {
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

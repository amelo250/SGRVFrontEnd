import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/features/auth/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login({
    required String correo,
    required String contrasena,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _authService.login(correo: correo, contrasena: contrasena);

      _isAuthenticated = true;

      return true;
    } catch (error) {
      _isAuthenticated = false;

      _errorMessage = error.toString().replaceFirst('Exception: ', '');

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<void> checkSession() async {
    _isAuthenticated = await _authService.isAuthenticated();

    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();

    _isAuthenticated = false;
    _errorMessage = null;

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}

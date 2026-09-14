import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sgrv_frontend/shared/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('inicia en modo claro cuando no hay preferencia guardada', () async {
    final provider = ThemeProvider();

    await provider.initialize();

    expect(provider.isDarkMode, isFalse);
    expect(provider.themeMode, ThemeMode.light);
  });

  test('activa y persiste el modo oscuro', () async {
    final provider = ThemeProvider();

    await provider.setDarkMode(true);
    final restoredProvider = ThemeProvider();
    await restoredProvider.initialize();

    expect(restoredProvider.isDarkMode, isTrue);
    expect(restoredProvider.themeMode, ThemeMode.dark);
  });
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/configuracion/pages/configuracion_page.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';
import 'package:sgrv_frontend/shared/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/configuracion/models/configuracion_catalogo.dart';
import 'package:sgrv_frontend/features/configuracion/providers/configuracion_provider.dart';
import 'package:sgrv_frontend/features/configuracion/services/configuracion_service.dart';

class ReloadingService extends ConfiguracionService {
  bool removed = false;
  @override
  Future<List<ConfiguracionCatalogoDefinition>> getDefinitions() async => [
    ConfiguracionCatalogoDefinition(key: 'estados', nombre: 'Estados'),
    if (!removed)
      ConfiguracionCatalogoDefinition(key: 'tipos', nombre: 'Tipos'),
  ];
  @override
  Future<List<ConfiguracionCatalogoItem>> getItems(
    ConfiguracionCatalogoDefinition definition, {
    required bool incluirInactivos,
  }) async => [];
}

void main() {
  testWidgets('selector movil sobrevive a recargas de catalogos', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final provider = ConfiguracionProvider(service: ReloadingService());
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: provider),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ConfiguracionPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await provider.select(provider.definitions.last);
    await tester.pumpAndSettle();
    await provider.initialize();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final dropdown = tester.widget<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    expect(dropdown.initialValue, 'tipos');
  });
  test(
    'reabrir configuracion conserva la clave con una instancia vigente',
    () async {
      final service = ReloadingService();
      final provider = ConfiguracionProvider(service: service);
      await provider.initialize();
      await provider.select(provider.definitions.last);
      final previous = provider.selected;
      await provider.initialize();
      expect(provider.selected!.key, 'tipos');
      expect(identical(previous, provider.selected), isFalse);
      expect(provider.definitions.contains(provider.selected), isTrue);
      service.removed = true;
      await provider.initialize();
      expect(provider.selected!.key, 'estados');
    },
  );
}

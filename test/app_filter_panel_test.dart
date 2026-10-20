import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sgrv_frontend/features/calendario/pages/calendario_page.dart';
import 'package:sgrv_frontend/features/calendario/providers/calendario_provider.dart';
import 'package:sgrv_frontend/features/calendario/services/calendario_service.dart';
import 'package:sgrv_frontend/features/calendario/models/calendario_evento.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class _CalendarService extends CalendarioService {
  @override
  Future<CalendarioResumen> obtener({
    required DateTime desde,
    required DateTime hasta,
    String? tipo,
    int? idVehiculo,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 30));
    return const CalendarioResumen(
      totalEventos: 0,
      totalReservaciones: 0,
      totalRentas: 0,
      eventos: [],
    );
  }
}

void main() {
  testWidgets(
    'Calendario conserva el panel abierto al aplicar un filtro móvil',
    (tester) async {
      await initializeDateFormatting('es');
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = CalendarioProvider(service: _CalendarService());
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            theme: AppTheme.dark,
            home: const CalendarioPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<String>), findsNothing);
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rentas'));
      await tester.pumpAndSettle();
      expect(provider.tipo, 'RENTA');
      expect(find.byType(SegmentedButton<String>), findsOneWidget);
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();
      expect(find.byType(SegmentedButton<String>), findsNothing);
      expect(provider.tipo, 'RENTA');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    },
  );
  for (final dark in [false, true]) {
    testWidgets(
      'Filtros conserva búsqueda y selección al cerrar: oscuro=$dark',
      (tester) async {
        var selected = false;
        var query = '';
        await tester.pumpWidget(
          MaterialApp(
            theme: dark ? AppTheme.dark : AppTheme.light,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => AppSearchPanel(
                  hint: 'Buscar cliente',
                  onChanged: (value) => query = value,
                  trailing: FilterChip(
                    label: const Text('Inactivos'),
                    selected: selected,
                    onSelected: (value) => setState(() => selected = value),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.byType(TextField), findsNothing);
        expect(find.text('Inactivos'), findsNothing);
        await tester.tap(find.text('Filtros'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Ana');
        await tester.tap(find.text('Inactivos'));
        await tester.pumpAndSettle();
        expect(query, 'Ana');
        expect(selected, isTrue);
        await tester.tap(find.text('Filtros'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        expect(query, 'Ana');
        expect(selected, isTrue);
        await tester.tap(find.text('Filtros'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller,
          isNull,
        );
        expect(find.text('Ana'), findsOneWidget);
        expect(
          tester.widget<FilterChip>(find.byType(FilterChip)).selected,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('Filtros grandes se desplazan sin ocultar resultados en móvil', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var applied = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Column(
            children: [
              AppFilterPanel(
                child: Column(
                  children: [
                    for (var i = 0; i < 15; i++)
                      SizedBox(height: 60, child: Text('Opción $i')),
                    TextButton(
                      onPressed: () => applied = true,
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ),
              const Expanded(child: Center(child: Text('Resultados'))),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Aplicar'), 180);
    await tester.tap(find.text('Aplicar'));
    await tester.pumpAndSettle();
    expect(applied, isTrue);
    expect(find.text('Resultados').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

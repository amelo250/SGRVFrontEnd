import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_task.dart';
import 'package:sgrv_frontend/features/dashboard/providers/dashboard_task_provider.dart';
import 'package:sgrv_frontend/features/dashboard/widgets/dashboard_tasks_section.dart';

class _Auth extends AuthProvider {
  _Auth(this.value);
  final String value;
  @override
  String? get role => value;
}

class _TaskProvider extends DashboardTaskProvider {
  _TaskProvider(this.task);
  final DashboardTask task;

  @override
  DashboardTaskStatus get status => DashboardTaskStatus.success;

  @override
  DashboardTasksResult get data => DashboardTasksResult(
    totalHoy: 1,
    totalProximas: 0,
    hoy: [task],
    proximas: const [],
  );
}

void main() {
  Future<void> showTask(
    WidgetTester tester, {
    required String tipo,
    required String codigo,
    bool completada = false,
    String role = "LECTOR",
  }) async {
    final provider = _TaskProvider(
      DashboardTask(
        id: 'test-1',
        tipo: tipo,
        idEntidad: 1,
        idVehiculo: 1,
        vehiculo: 'Vehículo de prueba',
        fecha: DateTime(2026, 10, 18, 10),
        titulo: 'Operación',
        estadoCodigo: codigo,
        esHoy: true,
        completada: completada,
      ),
    );
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<DashboardTaskProvider>.value(
        value: provider,
        child: ChangeNotifierProvider<AuthProvider>(
          create: (_) => _Auth(role),
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: DashboardTasksSection()),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('registrado no se presenta como pendiente ni permite completar', (
    tester,
  ) async {
    await showTask(tester, tipo: 'MANTENIMIENTO', codigo: 'REGISTRADO');
    expect(
      find.text('Operación · Registrado · estado no disponible'),
      findsOneWidget,
    );
    expect(find.byTooltip('Ver mantenimiento'), findsOneWidget);
    expect(find.byTooltip('Abrir para completar'), findsNothing);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'un booleano sin estado persistente no declara completado un mantenimiento',
    (tester) async {
      await showTask(
        tester,
        tipo: 'MANTENIMIENTO',
        codigo: 'REGISTRADO',
        completada: true,
      );
      final button = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton && widget.tooltip == 'Ver mantenimiento',
        ),
      );
      expect(button.onPressed, isNotNull);
      expect(find.textContaining('Completada'), findsNothing);
    },
  );

  testWidgets('entrega pendiente conserva su acción', (tester) async {
    await showTask(tester, tipo: 'ENTREGA', codigo: 'ACTIVA');
    expect(find.text('Operación · Pendiente'), findsOneWidget);
    final button = tester.widget<IconButton>(
      find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == 'Abrir para completar',
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'recepción completada conserva la marca y no permite otro cierre',
    (tester) async {
      await showTask(
        tester,
        tipo: 'RECEPCION',
        codigo: 'FINALIZADA',
        completada: true,
      );
      expect(find.text('Operación · Completada'), findsOneWidget);
      final button = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (widget) => widget is IconButton && widget.tooltip == 'Completada',
        ),
      );
      expect(button.onPressed, isNull);
    },
  );
  testWidgets('ADMIN puede completar mantenimiento pendiente desde tareas', (
    tester,
  ) async {
    await showTask(
      tester,
      tipo: 'MANTENIMIENTO',
      codigo: 'PENDIENTE',
      role: 'ADMIN',
    );
    expect(find.byTooltip('Completar mantenimiento'), findsOneWidget);
    expect(find.text('Operación · Pendiente'), findsOneWidget);
  });
  testWidgets('lector solo puede consultar mantenimiento pendiente', (
    tester,
  ) async {
    await showTask(tester, tipo: 'MANTENIMIENTO', codigo: 'PENDIENTE');
    expect(find.byTooltip('Completar mantenimiento'), findsNothing);
    expect(find.byTooltip('Ver mantenimiento'), findsOneWidget);
  });
  testWidgets(
    'mantenimiento completado queda marcado sin otra acción de cierre',
    (tester) async {
      await showTask(
        tester,
        tipo: 'MANTENIMIENTO',
        codigo: 'COMPLETADO',
        completada: true,
        role: 'ADMIN',
      );
      expect(find.text('Operación · Completada'), findsOneWidget);
      expect(find.byTooltip('Completar mantenimiento'), findsNothing);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/notificaciones/dtos/notificacion_resultado_dto.dart';
import 'package:sgrv_frontend/features/notificaciones/services/notificacion_service.dart';
import 'package:sgrv_frontend/features/notificaciones/widgets/contrato_notificacion_dialog.dart';

class FakeNotificacionService extends NotificacionService {
  final List<bool> calls = [];
  @override
  Future<List<NotificacionResultadoDto>> contrato(
    int id, {
    required bool correo,
    required bool whatsapp,
    required bool cliente,
    required bool empresa,
    required bool simular,
  }) async {
    calls.add(simular);
    return [
      NotificacionResultadoDto(
        destinatario: 'CLIENTE',
        canal: 'CORREO',
        estado: simular ? 'SIMULADO' : 'ACEPTADO',
        mensaje: 'Resultado de prueba',
      ),
    ];
  }
}

void main() {
  testWidgets('no envía al abrir y exige revisar antes del envío explícito', (
    tester,
  ) async {
    final service = FakeNotificacionService();
    addTearDown(service.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ContratoNotificacionDialog(rentaId: 1, service: service),
        ),
      ),
    );
    expect(service.calls, isEmpty);
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Enviar'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Revisar envío'));
    await tester.pumpAndSettle();
    expect(service.calls, [true]);
    expect(find.textContaining('Listo para enviar'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Enviar'));
    await tester.pumpAndSettle();
    expect(service.calls, [true, false]);
    expect(find.textContaining('Aceptado por el proveedor'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Enviar'), findsNothing);
  });
}

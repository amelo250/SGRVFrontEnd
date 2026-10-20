import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/rentas/widgets/signature_pad.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';

Future<void> drawSignature(WidgetTester tester) async {
  final canvas = find.byKey(const ValueKey('signature-canvas'));
  final start = tester.getTopLeft(canvas) + const Offset(30, 30);
  final gesture = await tester.startGesture(start);
  await gesture.moveTo(start + const Offset(30, 20));
  await gesture.moveTo(start + const Offset(90, 40));
  await gesture.moveTo(start + const Offset(130, 10));
  await gesture.up();
  await tester.pump();
}

Future<void> saveSignature(WidgetTester tester) async {
  await tester.tap(find.text('Guardar firma'));
  await tester.pump();
  // PNG encoding completes on the engine's real async queue, not fake time.
  for (
    var attempt = 0;
    attempt < 100 && find.text('Guardando…').evaluate().isNotEmpty;
    attempt++
  ) {
    await tester.runAsync(
      () async => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 16));
  }
  await tester.pumpAndSettle();
}

Future<GlobalKey<SignaturePadState>> mountPad(
  WidgetTester tester,
  Size size, {
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = GlobalKey<SignaturePadState>();
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark : AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 420,
            child: SignaturePad(key: key, label: 'Firma del cliente'),
          ),
        ),
      ),
    ),
  );
  return key;
}

void main() {
  for (final dark in [false, true]) {
    testWidgets('Web: modal centrado, firma PNG y cancelación: oscuro=$dark', (
      tester,
    ) async {
      final key = await mountPad(tester, const Size(1280, 900), dark: dark);
      expect(find.byKey(const ValueKey('signature-canvas')), findsNothing);
      await tester.tap(find.text('Firmar'));
      await tester.pumpAndSettle();
      final bounds = tester.getRect(
        find.byKey(const ValueKey('signature-dialog-content')),
      );
      expect(bounds.width, lessThanOrEqualTo(900));
      expect(bounds.top, greaterThan(0));
      expect(bounds.center.dx, closeTo(640, 1));
      await tester.tap(find.text('Guardar firma'));
      await tester.pumpAndSettle();
      expect(
        find.text('Debe dibujar una firma antes de guardar.'),
        findsOneWidget,
      );
      expect(key.currentState!.isEmpty, isTrue);
      await drawSignature(tester);
      await saveSignature(tester);
      expect(find.byType(Dialog), findsNothing);
      final png = await key.currentState!.exportPng();
      expect(png, isNotNull);
      expect(png!.take(8).toList(), [137, 80, 78, 71, 13, 10, 26, 10]);
      expect(key.currentState!.isEmpty, isFalse);
      await tester.runAsync(() async {
        final codec = await ui.instantiateImageCodec(png);
        final frame = await codec.getNextFrame();
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        var ink = false;
        for (var i = 0; i < pixels!.lengthInBytes; i += 4) {
          if (pixels.getUint8(i) < 70 &&
              pixels.getUint8(i + 1) < 70 &&
              pixels.getUint8(i + 2) < 100) {
            ink = true;
            break;
          }
        }
        expect(ink, isTrue, reason: 'El PNG exportado debe incluir los trazos');
        frame.image.dispose();
        codec.dispose();
      });
      await tester.tap(find.text('Editar firma'));
      await tester.pumpAndSettle();
      await saveSignature(tester);
      expect(await key.currentState!.exportPng(), orderedEquals(png));
      await tester.tap(find.text('Editar firma'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Limpiar'));
      await drawSignature(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(await key.currentState!.exportPng(), orderedEquals(png));
      expect(tester.takeException(), isNull);
    });
  }

  for (final size in [const Size(360, 800), const Size(844, 390)]) {
    testWidgets(
      'Móvil: pantalla completa y limpiar sin guardar: $size',
      (tester) async {
        final key = await mountPad(tester, size, dark: true);
        await tester.tap(find.text('Firmar'));
        await tester.pumpAndSettle();
        expect(tester.getSize(find.byType(Dialog)), size);
        expect(find.text('Limpiar').hitTestable(), findsOneWidget);
        expect(find.text('Guardar firma').hitTestable(), findsOneWidget);
        await drawSignature(tester);
        await tester.tap(find.text('Limpiar'));
        await tester.tap(find.text('Guardar firma'));
        await tester.pumpAndSettle();
        expect(
          find.text('Debe dibujar una firma antes de guardar.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();
        expect(key.currentState!.isEmpty, isTrue);
        expect(await key.currentState!.exportPng(), isNull);
        expect(tester.takeException(), isNull);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.iOS),
    );
  }

  testWidgets(
    'Las firmas de cliente y agente mantienen estados independientes',
    (tester) async {
      final client = GlobalKey<SignaturePadState>();
      final agent = GlobalKey<SignaturePadState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Column(
              children: [
                SignaturePad(key: client, label: 'Cliente'),
                SignaturePad(key: agent, label: 'Agente'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Firmar').first);
      await tester.pumpAndSettle();
      await drawSignature(tester);
      await saveSignature(tester);
      expect(client.currentState!.isEmpty, isFalse);
      expect(agent.currentState!.isEmpty, isTrue);
      client.currentState!.clear();
      await tester.pump();
      expect(await client.currentState!.exportPng(), isNull);
    },
  );
}

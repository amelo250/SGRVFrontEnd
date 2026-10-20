import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/configuracion/widgets/personalizacion_contrato_panel.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';

void main() {
  for (final width in [320.0, 1280.0]) {
    testWidgets('Personalización temporal responsive y PDF válido: $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: PersonalizacionContratoPanel()))));
      expect(find.text('Personalización de contratos'), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(3));
      final dynamic state = tester.state(find.byType(PersonalizacionContratoPanel));
      final List<int> bytes = await state.generarMuestra(const Empresa(
        idEmpresa: 7, idPlan: 1, nombre: 'Empresa Siete', nombreComercial: 'Renta de prueba',
        rnc: '123456789', activo: true, correo: 'rentas@example.com',
      ), null);
      expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
      expect(ascii.decode(bytes.sublist(bytes.length - 20), allowInvalid: true), contains('%%EOF'));
      expect(tester.takeException(), isNull);
    });
  }
}

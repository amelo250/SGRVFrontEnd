import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'), (_) async => null);
  });
  test('Cambiar plan utiliza PATCH y solo envía el plan seleccionado', () async {
    final service = EmpresaService(apiClient: ApiClient(client: MockClient((request) async {
      expect(request.method, 'PATCH');
      expect(request.url.path, '/api/empresas/7/plan');
      expect(jsonDecode(request.body), {'idPlan': 3});
      return http.Response(jsonEncode({'success': true, 'message': 'Guardado', 'data': {'idEmpresa': 7, 'idPlan': 3}}), 200);
    })));
    addTearDown(service.dispose);
    expect((await service.cambiarPlan(7, 3)).idPlan, 3);
  });
  test('Conflicto de límite conserva el mensaje de API', () async {
    final service = EmpresaService(apiClient: ApiClient(client: MockClient((request) async =>
      http.Response(jsonEncode({'success': false, 'message': 'El plan no admite la flota.'}), 409))));
    addTearDown(service.dispose);
    await expectLater(service.cambiarPlan(7, 3), throwsA(isA<ApiException>().having((e) => e.message, 'mensaje', 'El plan no admite la flota.')));
  });
}

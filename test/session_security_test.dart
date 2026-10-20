import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/app/app.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/session/session_state.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });

  test('401 con HTML elimina la sesión antes de intentar decodificar JSON', () async {
    await TokenStorage.saveToken('old-token');
    final previous = SessionState.generation.value;
    final api = ApiClient(client: MockClient((_) async => http.Response('<html>401</html>', 401)));
    addTearDown(api.dispose);
    await expectLater(api.getJson('https://example.test/private'),
        throwsA(isA<ApiException>().having((x) => x.statusCode, 'status', 401)));
    expect(await TokenStorage.getToken(), isNull);
    expect(SessionState.generation.value, greaterThan(previous));
  });

  for (final status in [200, 401]) {
    test('Respuesta $status de una sesión antigua no afecta la sesión nueva', () async {
      await TokenStorage.saveToken('old-token');
      final sent = Completer<void>();
      final response = Completer<http.Response>();
      final api = ApiClient(client: MockClient((_) {
        sent.complete();
        return response.future;
      }));
      addTearDown(api.dispose);
      final pending = api.getJson('https://example.test/private');
      final assertion = expectLater(pending, throwsStateError);
      await sent.future;
      await TokenStorage.saveToken('new-token');
      response.complete(http.Response('{"success":true,"data":{"empresa":1}}', status));
      await assertion;
      expect(await TokenStorage.getToken(), 'new-token');
    });
  }

  test('Proveedor desmontado no notifica al terminar una solicitud anterior', () {
    final provider = SessionNotifier();
    var calls = 0;
    provider.addListener(() => calls++);
    provider.dispose();
    provider.notifyListeners();
    expect(calls, 0);
  });

  test('Token vencido o malformado no abre el dashboard', () async {
    await TokenStorage.saveToken('invalid');
    expect(await TokenStorage.hasToken(), isFalse);
    expect(await TokenStorage.getToken(), isNull);
  });

  test('Login tardío no reemplaza la identidad de una sesión nueva', () async {
    final previous = SessionState.generation.value;
    await TokenStorage.saveToken('new-token');
    await expectLater(TokenStorage.saveToken('late-login', expectedGeneration: previous), throwsStateError);
    expect(await TokenStorage.getToken(), 'new-token');
  });

  testWidgets('Cambio de sesión recrea proveedores y elimina rutas privadas', (tester) async {
    await tester.pumpWidget(const SgrvApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(LoginPage));
    final oldCompany = context.read<EmpresaProvider>();
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
        const Scaffold(body: Text('Detalle de la empresa anterior'))));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de la empresa anterior'), findsOneWidget);
    SessionState.changed();
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pumpAndSettle();
    expect(find.text('Detalle de la empresa anterior'), findsNothing);
    final newCompany = tester.element(find.byType(LoginPage)).read<EmpresaProvider>();
    expect(identical(oldCompany, newCompany), isFalse);
    oldCompany.notifyListeners();
    expect(tester.takeException(), isNull);
  });
}

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/auth/services/password_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  String token() =>
      'header.${base64Url.encode(utf8.encode(jsonEncode({'UsuarioId': '3'})))}.signature';

  test(
    'Recuperación pública no transmite JWT y conserva respuesta genérica',
    () async {
      await TokenStorage.saveToken(token());
      final service = PasswordService(
        client: MockClient((request) async {
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(jsonDecode(request.body)['email'], 'admin@example.test');
          return http.Response(
            '{"success":true,"message":"Si corresponde, recibirás instrucciones."}',
            200,
          );
        }),
      );
      addTearDown(service.dispose);
      expect(
        await service.request(' admin@example.test '),
        contains('instrucciones'),
      );
      expect(await TokenStorage.getToken(), isNotNull);
    },
  );
  test('Cambio propio envía contrato existente y cierra sesión', () async {
    await TokenStorage.saveToken(token());
    final service = PasswordService(
      authenticatedClient: ApiClient(
        client: MockClient((request) async {
          expect(request.url.path, '/api/usuarios/3/cambiar-password');
          expect(jsonDecode(request.body)['passwordActual'], 'Anterior123');
          return http.Response('{"success":true}', 200);
        }),
      ),
    );
    addTearDown(service.dispose);
    await service.change('Anterior123', 'Nueva123!', 'Nueva123!');
    expect(await TokenStorage.getToken(), isNull);
  });
  test(
    'Restablecer otro usuario envía empresa objetivo y conserva sesión propia',
    () async {
      await TokenStorage.saveToken(token());
      final service = PasswordService(
        authenticatedClient: ApiClient(
          client: MockClient((request) async {
            expect(request.url.path, '/api/usuarios/8/restablecer-password');
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['idEmpresa'], 9);
            expect(body.containsKey('passwordActual'), isFalse);
            return http.Response('{"success":true}', 200);
          }),
        ),
      );
      addTearDown(service.dispose);
      await service.reset(8, 9, 'Nueva123!', 'Nueva123!');
      expect(await TokenStorage.getToken(), isNotNull);
    },
  );
  test('Código inválido muestra error de API y no borra sesión', () async {
    await TokenStorage.saveToken(token());
    final service = PasswordService(
      client: MockClient(
        (_) async =>
            http.Response('{"success":false,"message":"Código inválido"}', 400),
      ),
    );
    addTearDown(service.dispose);
    await expectLater(
      service.recover('bad', 'Nueva123!', 'Nueva123!'),
      throwsA(isA<ApiException>()),
    );
    expect(await TokenStorage.getToken(), isNotNull);
  });
}

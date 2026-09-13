// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';

void main() {
  test('ApiResponse interpreta el contrato estándar del backend', () {
    final response = ApiResponse<String>.fromJson(
      {
        'success': true,
        'message': 'Operación correcta',
        'data': 'resultado',
        'timestamp': '2026-08-18T12:00:00Z',
      },
      (value) => value! as String,
    );

    expect(response.success, isTrue);
    expect(response.message, 'Operación correcta');
    expect(response.data, 'resultado');
    expect(response.timestamp, isNotNull);
  });
}

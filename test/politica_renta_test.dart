import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';

void main() {
  const policy = PoliticaRentaDto(minimoDias: 3);
  final start = DateTime.utc(2027, 1, 1, 10);
  test('mínimo y descuento siguen los días cobrados del servidor', () {
    expect(
      policy.validar(start, start.add(const Duration(days: 1)), 0),
      isNotNull,
    );
    expect(
      policy.validar(start, start.add(const Duration(days: 2)), 0),
      isNull,
    );
    expect(
      policy.validar(start, start.add(const Duration(days: 2)), 0.01),
      isNotNull,
    );
    expect(
      policy.permiteDescuento(start, start.add(const Duration(days: 2))),
      isFalse,
    );
    expect(
      policy.validar(start, start.add(const Duration(days: 4)), 10),
      isNull,
    );
    expect(
      policy.permiteDescuento(start, start.add(const Duration(days: 4))),
      isTrue,
    );
    expect(policy.dias(start, start.add(const Duration(days: 2, hours: 1))), 3);
    expect(
      policy.permiteDescuento(
        start,
        start.add(const Duration(days: 2, hours: 1)),
      ),
      isFalse,
    );
    expect(
      policy.dias(start, start.add(const Duration(days: 3, minutes: 1))),
      4,
    );
  });
  test('excepción de administrador y medianoche dominicana', () {
    expect(
      policy.validar(
        start,
        start.add(const Duration(days: 2)),
        10,
        permitirDescuentoMinimo: true,
      ),
      isNull,
    );
    expect(
      policy.validar(
        start,
        start.add(const Duration(days: 1)),
        10,
        permitirDescuentoMinimo: true,
      ),
      isNotNull,
    );
    expect(
      policy.dias(DateTime.utc(2027, 1, 7, 3), DateTime.utc(2027, 1, 9, 5)),
      4,
    );
  });
  test('política configurable e intervalos inválidos', () {
    final custom = PoliticaRentaDto.fromJson({'minimoDias': 5});
    expect(
      custom.validar(start, start.add(const Duration(days: 3)), 0),
      isNotNull,
    );
    expect(
      custom.permiteDescuento(start, start.add(const Duration(days: 4))),
      isFalse,
    );
    expect(
      custom.permiteDescuento(start, start.add(const Duration(days: 6))),
      isTrue,
    );
    expect(custom.validar(start, start, 0), isNotNull);
    expect(
      custom.validar(start, start.subtract(const Duration(days: 1)), 0),
      isNotNull,
    );
  });
}

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/vehiculos/models/foto_vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_accesorio.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_media_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/services/vehiculo_media_service.dart';

FotoVehiculo photo(int id) => FotoVehiculo(
  idFoto: id,
  url: '/foto/$id',
  esPrincipal: false,
  orden: id,
  rowVersion: 'AAAAAAAAAAA=',
);

class Media extends VehiculoMediaService {
  Media(int count) : items = List.generate(count, photo);
  List<FotoVehiculo> items;
  int uploads = 0;
  Completer<void>? gate;
  bool conflict = false;
  @override
  Future<List<Accesorio>> catalogo() async => [];
  @override
  Future<List<VehiculoAccesorio>> accesorios(int id) async => [];
  @override
  Future<List<FotoVehiculo>> fotos(int id) async => List.of(items);
  @override
  Future<FotoVehiculo> subir(
    int id,
    List<int> bytes,
    String name,
    String type, {
    bool principal = false,
  }) async {
    uploads++;
    if (gate != null) await gate!.future;
    if (conflict) {
      items.add(photo(99));
      throw const ApiException(
        message: 'Se permite un máximo de 4 fotos activas por vehículo.',
        statusCode: 409,
      );
    }
    final item = photo(99);
    items.add(item);
    return item;
  }

  @override
  Future<void> eliminarFoto(int v, int f) async {
    items.removeWhere((x) => x.idFoto == f);
  }
}

void main() {
  test('permite cuarta foto y bloquea quinta sin enviarla', () async {
    final service = Media(3);
    final provider = VehiculoMediaProvider(service: service);
    addTearDown(provider.dispose);
    await provider.cargar(12);
    expect(provider.puedeSubirFoto, isTrue);
    expect(await provider.subir(12, [1], 'foto.png', 'image/png'), isTrue);
    expect(provider.fotos.length, 4);
    expect(provider.puedeSubirFoto, isFalse);
    expect(await provider.subir(12, [1], 'foto.png', 'image/png'), isFalse);
    expect(service.uploads, 1);
    expect(provider.error, contains('4 fotos'));
  });
  test('eliminar foto libera cupo', () async {
    final provider = VehiculoMediaProvider(service: Media(4));
    addTearDown(provider.dispose);
    await provider.cargar(12);
    await provider.eliminar(12, 0);
    expect(provider.fotos.length, 3);
    expect(provider.puedeSubirFoto, isTrue);
  });
  test('historial con más de cuatro se conserva y bloquea carga', () async {
    final service = Media(6);
    final provider = VehiculoMediaProvider(service: service);
    addTearDown(provider.dispose);
    await provider.cargar(12);
    expect(provider.fotos.length, 6);
    expect(await provider.subir(12, [1], 'foto.png', 'image/png'), isFalse);
    expect(service.uploads, 0);
  });
  test('conflicto remoto actualiza cupo y conserva mensaje de API', () async {
    final service = Media(3)..conflict = true;
    final provider = VehiculoMediaProvider(service: service);
    addTearDown(provider.dispose);
    await provider.cargar(12);
    expect(await provider.subir(12, [1], 'foto.png', 'image/png'), isFalse);
    expect(provider.fotos.length, 4);
    expect(
      provider.error,
      'Se permite un máximo de 4 fotos activas por vehículo.',
    );
    expect(provider.subiendo, isFalse);
  });
  test('no envía dos cargas locales simultáneas', () async {
    final service = Media(3)..gate = Completer<void>();
    final provider = VehiculoMediaProvider(service: service);
    addTearDown(provider.dispose);
    await provider.cargar(12);
    final first = provider.subir(12, [1], 'foto.png', 'image/png');
    expect(provider.subiendo, isTrue);
    expect(await provider.subir(12, [1], 'foto.png', 'image/png'), isFalse);
    service.gate!.complete();
    expect(await first, isTrue);
    expect(service.uploads, 1);
    expect(provider.subiendo, isFalse);
  });
}

import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/session/session_state.dart';
import '../models/foto_vehiculo.dart';
import '../models/vehiculo_accesorio.dart';
import '../services/vehiculo_media_service.dart';

class VehiculoMediaProvider extends SessionNotifier {
  VehiculoMediaProvider({VehiculoMediaService? service})
    : _service = service ?? VehiculoMediaService();
  final VehiculoMediaService _service;
  List<Accesorio> catalogo = const [];
  List<VehiculoAccesorio> asignados = const [];
  List<FotoVehiculo> fotos = const [];
  bool loading = false;
  String? error;
  Future<void> cargar(int id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final values = await Future.wait([
        _service.catalogo(),
        _service.accesorios(id),
        _service.fotos(id),
      ]);
      catalogo = values[0] as List<Accesorio>;
      asignados = values[1] as List<VehiculoAccesorio>;
      fotos = values[2] as List<FotoVehiculo>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> alternar(int vehiculo, Accesorio item, bool value) async {
    try {
      if (value) {
        await _service.asignar(vehiculo, item.id);
      } else {
        await _service.retirar(vehiculo, item.id);
      }
      await cargar(vehiculo);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  static const maxFotosPorVehiculo = 4;
  bool subiendo = false;
  bool get limiteFotosAlcanzado => fotos.length >= maxFotosPorVehiculo;
  bool get puedeSubirFoto => !loading && !subiendo && !limiteFotosAlcanzado;

  Future<bool> subir(
    int vehiculo,
    List<int> bytes,
    String name,
    String type,
  ) async {
    if (loading || subiendo) return false;
    if (limiteFotosAlcanzado) {
      error =
          'Se permite un máximo de 4 fotos por vehículo. Elimina una foto antes de agregar otra.';
      notifyListeners();
      return false;
    }
    subiendo = true;
    error = null;
    notifyListeners();
    try {
      await _service.subir(
        vehiculo,
        bytes,
        name,
        type,
        principal: fotos.isEmpty,
      );
      await cargar(vehiculo);
      return true;
    } on ApiException catch (e) {
      // Otra sesión pudo ocupar el último cupo: actualizar la galería y conservar el mensaje.
      if (e.statusCode == 409) await cargar(vehiculo);
      error = e.message;
      return false;
    } catch (_) {
      error = 'No fue posible cargar la foto.';
      return false;
    } finally {
      subiendo = false;
      notifyListeners();
    }
  }

  Future<void> hacerPrincipal(int v, int f) async {
    await _service.principal(v, f);
    await cargar(v);
  }

  Future<void> eliminar(int v, int f) async {
    await _service.eliminarFoto(v, f);
    await cargar(v);
  }
}

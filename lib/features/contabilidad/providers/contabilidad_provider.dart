import 'package:flutter/foundation.dart';
import '../models/contabilidad_resumen.dart';
import '../services/contabilidad_service.dart';

class ContabilidadProvider extends ChangeNotifier {
  ContabilidadProvider({ContabilidadService? service})
    : _service = service ?? ContabilidadService();
  final ContabilidadService _service;
  ContabilidadResumen? data;
  DateTime? desde, hasta;
  String tipo = 'TODOS', categoria = 'TODAS';
  bool loading = false;
  String? error;
  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      data = await _service.get(
        desde: desde,
        hasta: hasta,
        tipo: tipo,
        categoria: categoria,
      );
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setDates(DateTime? from, DateTime? to) async {
    desde = from;
    hasta = to;
    await load();
  }

  Future<void> setType(String value) async {
    tipo = value;
    categoria = 'TODAS';
    await load();
  }

  Future<void> setCategory(String value) async {
    categoria = value;
    await load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

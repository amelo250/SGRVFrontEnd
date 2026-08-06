import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/calendario/models/calendario_evento.dart';
import 'package:sgrv_frontend/features/calendario/services/calendario_service.dart';

enum CalendarioStatus { initial, loading, success, empty, error }

class CalendarioProvider extends ChangeNotifier {
  CalendarioProvider({CalendarioService? service})
    : _service = service ?? CalendarioService(),
      _mesVisible = DateTime(DateTime.now().year, DateTime.now().month),
      _diaSeleccionado = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

  final CalendarioService _service;
  CalendarioStatus _status = CalendarioStatus.initial;
  CalendarioResumen? _resumen;
  String? _errorMessage;
  late DateTime _mesVisible;
  late DateTime _diaSeleccionado;
  String? _tipo;
  int _requestVersion = 0;

  CalendarioStatus get status => _status;
  CalendarioResumen? get resumen => _resumen;
  String? get errorMessage => _errorMessage;
  DateTime get mesVisible => _mesVisible;
  DateTime get diaSeleccionado => _diaSeleccionado;
  String? get tipo => _tipo;
  List<CalendarioEvento> get eventos => _resumen?.eventos ?? const [];

  List<CalendarioEvento> eventosDelDia(DateTime day) => eventos
      .where((event) {
        final inicio = DateTime(
          event.fechaInicio.year,
          event.fechaInicio.month,
          event.fechaInicio.day,
        );
        final fin = DateTime(
          event.fechaFin.year,
          event.fechaFin.month,
          event.fechaFin.day,
        );
        final fecha = DateTime(day.year, day.month, day.day);
        return !fecha.isBefore(inicio) && !fecha.isAfter(fin);
      })
      .toList(growable: false);

  Future<void> cargar({bool refresh = false}) async {
    final version = ++_requestVersion;
    if (!refresh) _status = CalendarioStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final desde = DateTime(_mesVisible.year, _mesVisible.month, 1);
      final hasta = DateTime(_mesVisible.year, _mesVisible.month + 1, 1);
      final result = await _service.obtener(
        desde: desde,
        hasta: hasta,
        tipo: _tipo,
      );
      if (version != _requestVersion) return;
      _resumen = result;
      _status = result.eventos.isEmpty
          ? CalendarioStatus.empty
          : CalendarioStatus.success;
    } on ApiException catch (error) {
      if (version != _requestVersion) return;
      _errorMessage = error.message;
      _status = CalendarioStatus.error;
    } catch (_) {
      if (version != _requestVersion) return;
      _errorMessage = 'No fue posible cargar el calendario.';
      _status = CalendarioStatus.error;
    }
    if (version == _requestVersion) notifyListeners();
  }

  Future<void> cambiarMes(int offset) async {
    _mesVisible = DateTime(_mesVisible.year, _mesVisible.month + offset);
    _diaSeleccionado = DateTime(_mesVisible.year, _mesVisible.month, 1);
    await cargar();
  }

  void seleccionarDia(DateTime day) {
    _diaSeleccionado = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  Future<void> filtrarTipo(String? value) async {
    _tipo = value;
    await cargar();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

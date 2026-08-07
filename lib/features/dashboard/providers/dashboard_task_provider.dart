import 'package:flutter/foundation.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_task.dart';
import 'package:sgrv_frontend/features/dashboard/services/dashboard_task_service.dart';

enum DashboardTaskStatus { initial, loading, success, empty, error }

class DashboardTaskProvider extends ChangeNotifier {
  DashboardTaskProvider({DashboardTaskService? service})
    : _service = service ?? DashboardTaskService();
  final DashboardTaskService _service;
  DashboardTaskStatus _status = DashboardTaskStatus.initial;
  DashboardTasksResult? _data;
  String? _error;

  DashboardTaskStatus get status => _status;
  DashboardTasksResult? get data => _data;
  String? get error => _error;

  Future<void> load({bool refresh = false}) async {
    if (!refresh) _status = DashboardTaskStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _data = await _service.get();
      _status = (_data!.hoy.isEmpty && _data!.proximas.isEmpty)
          ? DashboardTaskStatus.empty
          : DashboardTaskStatus.success;
    } on ApiException catch (error) {
      _error = error.message;
      _status = DashboardTaskStatus.error;
    } catch (_) {
      _error = 'No fue posible cargar las tareas operativas.';
      _status = DashboardTaskStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}

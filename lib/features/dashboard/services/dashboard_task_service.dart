import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/network/api_response.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_task.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_summary.dart';

class DashboardTaskService {
  DashboardTaskService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<DashboardTasksResult> get({int days = 7, int limit = 8}) async {
    final now = DateTime.now();
    final uri = Uri.parse(ApiConfig.dashboardTasks).replace(
      queryParameters: {
        'fecha':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-'
            '${now.day.toString().padLeft(2, '0')}',
        'dias': '$days',
        'limite': '$limit',
      },
    );
    final response = ApiResponse<DashboardTasksResult>.fromJson(
      await _client.getJson(uri.toString()),
      (value) => DashboardTasksResult.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  Future<DashboardSummary> getSummary() async {
    final response = ApiResponse<DashboardSummary>.fromJson(
      await _client.getJson(ApiConfig.dashboardSummary),
      (value) => DashboardSummary.fromJson(value as Map<String, dynamic>),
    );
    if (!response.success || response.data == null) {
      throw ApiException(message: response.message);
    }
    return response.data!;
  }

  void dispose() => _client.dispose();
}

import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/dashboard/pages/dashboard_page.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/dashboard/providers/dashboard_task_provider.dart';
import 'package:sgrv_frontend/features/administracion/pages/administracion_dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String?> _sessionRole() async {
    if (!await TokenStorage.hasToken()) return null;
    return await TokenStorage.getRole() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _sessionRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == 'SUPADMIN') {
          return const AdministracionDashboardPage();
        }

        if (snapshot.data != null) {
          return ChangeNotifierProvider(
            create: (_) => DashboardTaskProvider(),
            child: const DashboardPage(),
          );
        }

        return const LoginPage();
      },
    );
  }
}

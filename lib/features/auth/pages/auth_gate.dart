import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/storage/token_storage.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/dashboard/pages/dashboard_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasSession() {
    return TokenStorage.hasToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const DashboardPage();
        }

        return const LoginPage();
      },
    );
  }
}

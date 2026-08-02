import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/pages/auth_gate.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';

class SgrvApp extends StatelessWidget {
  const SgrvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
      ],
      child: MaterialApp(
        title: 'SGRV',
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}

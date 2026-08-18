import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';
import 'package:sgrv_frontend/shared/colors/app_colors.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import 'package:sgrv_frontend/features/empresas/pages/empresa_onboarding_page.dart';
import 'dart:convert';
import 'package:sgrv_frontend/core/storage/token_storage.dart';

class EmpresasPage extends StatefulWidget {
  const EmpresasPage({super.key});

  @override
  State<EmpresasPage> createState() => _EmpresasPageState();
}

class _EmpresasPageState extends State<EmpresasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<EmpresaProvider>().cargarEmpresas(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmpresaProvider>();
    return AppModuleScaffold(
      title: 'Empresas',
      subtitle: 'Consulta las organizaciones y planes asociados a tu cuenta.',
      body: Column(
        children: [
          FutureBuilder<bool>(
            future: _isSupAdmin(),
            builder: (_, s) => s.data == true
                ? Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final created = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmpresaOnboardingPage(),
                          ),
                        );
                        if (created == true && mounted) {
                          await provider.cargarEmpresas();
                        }
                      },
                      icon: const Icon(Icons.add_business_outlined),
                      label: const Text('Nueva empresa'),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(EmpresaProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.errorMessage != null) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar las empresas',
        message: provider.errorMessage,
        onRetry: provider.cargarEmpresas,
      );
    }
    if (provider.empresas.isEmpty) {
      return const AppStateView(
        icon: Icons.business_outlined,
        title: 'No hay empresas registradas',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.cargarEmpresas,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 1000 ? 2 : 1,
          mainAxisExtent: 190,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: provider.empresas.length,
        itemBuilder: (_, index) {
          final company = provider.empresas[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            company.nombre.isEmpty
                                ? '?'
                                : company.nombre[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            Text(
                              company.nombreComercial.isEmpty
                                  ? 'Empresa registrada'
                                  : company.nombreComercial,
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Chip(
                        avatar: Icon(
                          company.activo ? Icons.check_circle : Icons.cancel,
                          size: 17,
                          color: company.activo
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        label: Text(company.activo ? 'Activa' : 'Inactiva'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: _detail(
                          Icons.badge_outlined,
                          'RNC',
                          company.rnc.isEmpty ? 'No registrado' : company.rnc,
                        ),
                      ),
                      Expanded(
                        child: _detail(
                          Icons.workspace_premium_outlined,
                          'Plan',
                          '#${company.idPlan}',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detail(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 20, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ],
  );

  Future<bool> _isSupAdmin() async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;
    try {
      final part = base64Url.normalize(token.split('.')[1]);
      final json =
          jsonDecode(utf8.decode(base64Url.decode(part)))
              as Map<String, dynamic>;
      return json.values.any((v) => v == 'SUPADMIN');
    } catch (_) {
      return false;
    }
  }
}

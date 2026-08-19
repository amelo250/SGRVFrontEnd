import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/administracion/providers/administracion_provider.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/configuracion/pages/configuracion_page.dart';
import 'package:sgrv_frontend/features/empresas/pages/empresa_page.dart';
import 'usuarios_admin_page.dart';

class AdministracionDashboardPage extends StatefulWidget {
  const AdministracionDashboardPage({super.key});
  @override
  State<AdministracionDashboardPage> createState() =>
      _AdministracionDashboardPageState();
}

class _AdministracionDashboardPageState
    extends State<AdministracionDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AdministracionProvider>().load(),
    );
  }

  void _open(Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdministracionProvider>();
    final data = provider.resumen;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Administración SGRV'),
        actions: [
          IconButton(
            onPressed: provider.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: provider.loading && data == null
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && data == null
          ? Center(child: Text(provider.error!))
          : RefreshIndicator(
              onRefresh: provider.load,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Text(
                    'Panel de superadministración',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Control global de empresas, usuarios y catálogos.',
                    style: TextStyle(color: Color(0xFF7B8498)),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _metric(
                        'Empresas',
                        '${data?.empresasActivas ?? 0}/${data?.empresasTotal ?? 0}',
                        Icons.business_rounded,
                      ),
                      _metric(
                        'Usuarios',
                        '${data?.usuariosActivos ?? 0}/${data?.usuariosTotal ?? 0}',
                        Icons.people_rounded,
                      ),
                      _metric(
                        'Catálogos',
                        '${data?.catalogosConfigurables ?? 0}',
                        Icons.tune_rounded,
                      ),
                      _metric(
                        'Vehículos',
                        '${data?.vehiculosTotal ?? 0}',
                        Icons.directions_car_rounded,
                      ),
                      _metric(
                        'Clientes',
                        '${data?.clientesTotal ?? 0}',
                        Icons.badge_rounded,
                      ),
                      _metric(
                        'Rentas',
                        '${data?.rentasTotal ?? 0}',
                        Icons.key_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _action(
                        'Administrar empresas',
                        'Onboarding, consulta y estado',
                        Icons.domain_rounded,
                        () => _open(const EmpresasPage()),
                      ),
                      _action(
                        'Administrar usuarios',
                        'Usuarios de todas las empresas',
                        Icons.manage_accounts_rounded,
                        () => _open(const UsuariosAdminPage()),
                      ),
                      _action(
                        'Mantener catálogos',
                        'Estados, tipos, monedas y más',
                        Icons.settings_suggest_rounded,
                        () => _open(const ConfiguracionPage()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Empresas recientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final company
                              in data?.empresasRecientes ?? const [])
                            ListTile(
                              leading: Icon(
                                company.activo
                                    ? Icons.check_circle
                                    : Icons.pause_circle,
                                color: company.activo
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text(company.nombre),
                              subtitle: Text(
                                'Empresa #${company.idEmpresa} · ${company.usuarios} usuarios',
                              ),
                              trailing: Text(
                                company.activo ? 'Activa' : 'Inactiva',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _metric(String title, String value, IconData icon) => SizedBox(
    width: 210,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  Widget _action(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) => SizedBox(
    width: 340,
    child: Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_rounded),
      ),
    ),
  );
}

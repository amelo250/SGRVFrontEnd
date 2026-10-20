import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:flutter/material.dart';
import 'package:sgrv_frontend/shared/theme/theme_provider.dart';
import 'package:sgrv_frontend/features/auth/pages/password_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/calendario/pages/calendario_page.dart';
import 'package:sgrv_frontend/features/clientes/pages/clientes_page.dart';
import 'package:sgrv_frontend/features/clientes/pages/cliente_form_page.dart';
import 'package:sgrv_frontend/features/configuracion/pages/configuracion_page.dart';
import 'package:sgrv_frontend/features/contabilidad/pages/contabilidad_page.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_summary.dart';
import 'package:sgrv_frontend/features/dashboard/providers/dashboard_task_provider.dart';
import 'package:sgrv_frontend/features/dashboard/widgets/dashboard_tasks_section.dart';
import 'package:sgrv_frontend/features/dashboard/widgets/dashboard_quick_actions.dart';
import 'package:sgrv_frontend/features/dashboard/widgets/dashboard_quick_actions_fab.dart';
import 'package:sgrv_frontend/features/empresas/pages/empresa_page.dart';
import 'package:sgrv_frontend/features/gastos/pages/gastos_page.dart';
import 'package:sgrv_frontend/features/gastos/pages/gasto_form_page.dart';
import 'package:sgrv_frontend/features/mantenimientos/pages/mantenimientos_page.dart';
import 'package:sgrv_frontend/features/mantenimientos/pages/mantenimiento_form_page.dart';
import 'package:sgrv_frontend/features/pagos/pages/pagos_page.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_form_page.dart';
import 'package:sgrv_frontend/features/proveedores/pages/proveedores_vehiculos_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/rentas_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_form_page.dart';
import 'package:sgrv_frontend/features/reservaciones/pages/reservaciones_page.dart';
import 'package:sgrv_frontend/features/reservaciones/pages/reservacion_form_page.dart';
import 'package:sgrv_frontend/features/vehiculos/pages/vehiculos_page.dart';
import 'package:sgrv_frontend/features/vehiculos/pages/vehiculo_form_page.dart';
import 'package:sgrv_frontend/shared/widgets/app_logo.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const _nav = <({String label, IconData icon, Widget page})>[
    (
      label: 'Reservas',
      icon: Icons.event_note_rounded,
      page: ReservacionesPage(),
    ),
    (label: 'Rentas', icon: Icons.key_rounded, page: RentasPage()),
    (
      label: 'Vehículos',
      icon: Icons.directions_car_rounded,
      page: VehiculosPage(),
    ),
    (
      label: 'Mantenimientos',
      icon: Icons.build_rounded,
      page: MantenimientosPage(),
    ),
    (label: 'Clientes', icon: Icons.people_rounded, page: ClientesPage()),
    (label: 'Pagos', icon: Icons.payments_rounded, page: PagosPage()),
    (label: 'Gastos', icon: Icons.receipt_long_rounded, page: GastosPage()),
    (
      label: 'Contabilidad',
      icon: Icons.account_balance_rounded,
      page: ContabilidadPage(),
    ),
    (
      label: 'Calendario',
      icon: Icons.calendar_month_rounded,
      page: CalendarioPage(),
    ),
    (label: 'Empresas', icon: Icons.business_rounded, page: EmpresasPage()),
    (
      label: 'Proveedores',
      icon: Icons.handshake_rounded,
      page: ProveedoresVehiculosPage(),
    ),
    (
      label: 'Configuración',
      icon: Icons.settings_rounded,
      page: ConfiguracionPage(),
    ),
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<DashboardTaskProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<DashboardTaskProvider>();
    final s = p.summary;
    final desktop = MediaQuery.sizeOf(context).width >= 1100;
    final theme = Theme.of(context);
    return Row(
      children: [
        if (desktop)
          SizedBox(
            width: 236,
            child: Material(
              color: theme.scaffoldBackgroundColor,
              shape: Border(
                right: BorderSide(color: theme.colorScheme.outline),
              ),
              child: _menu(s, persistent: true),
            ),
          ),
        Expanded(
          child: Scaffold(
            drawer: desktop ? null : Drawer(child: _menu(s)),
            appBar: AppBar(
              title: const Text(
                'Dashboard',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              shape: Border(
                bottom: BorderSide(color: theme.colorScheme.outline),
              ),
              actions: [
                if (MediaQuery.sizeOf(context).width < 600)
                  PopupMenuButton<String>(
                    tooltip: 'Opciones',
                    onSelected: (value) {
                      if (value == 'theme') {
                        final t = context.read<ThemeProvider>();
                        t.setDarkMode(!t.isDarkMode);
                      }
                      if (value == 'refresh') p.load(refresh: true);
                      if (value == 'logout') _logout();
                      if (value == 'password')
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PasswordPage(mode: PasswordMode.change),
                          ),
                        );
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'theme',
                        child: Text('Cambiar tema'),
                      ),
                      PopupMenuItem(
                        value: 'password',
                        child: Text('Cambiar mi contraseña'),
                      ),
                      PopupMenuItem(
                        value: 'refresh',
                        child: Text('Actualizar'),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Cerrar sesión'),
                      ),
                    ],
                  )
                else ...[
                  IconButton(
                    tooltip: context.watch<ThemeProvider>().isDarkMode
                        ? 'Activar tema claro'
                        : 'Activar tema oscuro',
                    icon: Icon(
                      context.watch<ThemeProvider>().isDarkMode
                          ? Icons.light_mode_outlined
                          : Icons.dark_mode_outlined,
                    ),
                    onPressed: () {
                      final theme = context.read<ThemeProvider>();
                      theme.setDarkMode(!theme.isDarkMode);
                    },
                  ),
                  IconButton(
                    tooltip: 'Cambiar mi contraseña',
                    icon: const Icon(Icons.lock_outline),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PasswordPage(mode: PasswordMode.change),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => p.load(refresh: true),
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ],
            ),
            floatingActionButton: DashboardQuickActionsFab(
              actions: _quickActions(),
            ),
            body: p.status == DashboardTaskStatus.loading && s == null
                ? const Center(child: CircularProgressIndicator())
                : p.status == DashboardTaskStatus.error && s == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.error ?? 'No fue posible cargar el dashboard.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: p.load,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : _content(p, s),
          ),
        ),
      ],
    );
  }

  List<DashboardQuickAction> _quickActions() => [
    DashboardQuickAction(
      title: 'Nueva renta',
      subtitle: 'Registrar alquiler',
      icon: Icons.key_rounded,
      color: const Color(0xFF3867F4),
      onTap: () => _openQuickAction(const RentaFormPage()),
    ),
    DashboardQuickAction(
      title: 'Nuevo vehículo',
      subtitle: 'Agregar a la flota',
      icon: Icons.directions_car_rounded,
      color: const Color(0xFF7057F5),
      onTap: () => _openQuickAction(const VehiculoFormPage()),
    ),
    DashboardQuickAction(
      title: 'Mantenimiento',
      subtitle: 'Registrar servicio',
      icon: Icons.build_circle_rounded,
      color: const Color(0xFFFF8A34),
      onTap: () => _openQuickAction(const MantenimientoFormPage()),
    ),
    DashboardQuickAction(
      title: 'Reservación',
      subtitle: 'Separar vehículo',
      icon: Icons.event_available_rounded,
      color: const Color(0xFF1A9B72),
      onTap: () => _openQuickAction(const ReservacionFormPage()),
    ),
    DashboardQuickAction(
      title: 'Nuevo cliente',
      subtitle: 'Registrar persona',
      icon: Icons.person_add_alt_1_rounded,
      color: const Color(0xFF2F9DFF),
      onTap: () => _openQuickAction(const ClienteFormPage()),
    ),
    DashboardQuickAction(
      title: 'Registrar pago',
      subtitle: 'Aplicar a una renta',
      icon: Icons.add_card_rounded,
      color: const Color(0xFF2EBE7E),
      onTap: () => _openQuickAction(const PagoFormPage()),
    ),
    DashboardQuickAction(
      title: 'Registrar gasto',
      subtitle: 'Control financiero',
      icon: Icons.receipt_long_rounded,
      color: const Color(0xFFE05A67),
      onTap: () => _openQuickAction(const GastoFormPage()),
    ),
  ];

  Future<void> _openQuickAction(Widget page) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) {
      await context.read<DashboardTaskProvider>().load(refresh: true);
    }
  }

  Widget _menu(DashboardSummary? s, {bool persistent = false}) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 74,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppLogo(
                    compact: true,
                    color: scheme.onSurface,
                    imageUrl: s?.empresa.logoUrl,
                    title: 'SGRV',
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                ListTile(
                  dense: true,
                  selected: true,
                  selectedColor: Colors.white,
                  selectedTileColor: const Color(0xFF278C54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  leading: const Icon(Icons.space_dashboard_outlined, size: 19),
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    if (!persistent) Navigator.pop(context);
                  },
                ),
                for (var i = 0; i < _nav.length; i++) ...[
                  if (i == 0 || i == 5 || i == 9)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 24, 12, 8),
                      child: Text(
                        i == 0
                            ? 'OPERACIONES'
                            : i == 5
                            ? 'FINANZAS'
                            : 'ADMINISTRACIÓN',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 1.3,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(_nav[i].icon, size: 18),
                    title: Text(
                      _nav[i].label,
                      style: const TextStyle(fontSize: 13),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onTap: () {
                      if (!persistent) Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => _nav[i].page),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.business_outlined, size: 20),
            title: Text(
              s?.empresa.nombreComercial.isNotEmpty == true
                  ? s!.empresa.nombreComercial
                  : 'Mi empresa',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Gestión de rentas',
              style: TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(DashboardTaskProvider p, DashboardSummary? s) {
    if (s == null) {
      return const Center(child: Text('Sin información disponible.'));
    }
    final money = NumberFormat.currency(locale: 'es_DO', symbol: 'DOP ');
    return RefreshIndicator(
      onRefresh: () => p.load(refresh: true),
      child: ListView(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width < 700 ? 16 : 32,
        ),
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rendimiento del negocio y operaciones de tu flota',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          _brand(s.empresa),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (_, c) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: c.maxWidth >= 1000
                  ? 3
                  : c.maxWidth >= 620
                  ? 2
                  : 1,
              mainAxisExtent: 126,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _metric(
                  'Reservas hoy',
                  '${s.reservasHoy}',
                  Icons.event_available,
                ),
                _metric(
                  'Vehículos alquilados',
                  '${s.vehiculosAlquilados}',
                  Icons.car_rental,
                ),
                _metric(
                  'Ingresos hoy',
                  money.format(s.ingresosHoy),
                  Icons.payments,
                ),
                _metric(
                  'Clientes activos',
                  '${s.clientesActivos}',
                  Icons.people,
                ),
                _metric(
                  'Ingresos del mes',
                  money.format(s.ingresosMes),
                  Icons.trending_up,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const DashboardTasksSection(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (_, c) => c.maxWidth >= 850
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _reservations(s)),
                      const SizedBox(width: 16),
                      Expanded(child: _categories(s)),
                    ],
                  )
                : Column(
                    children: [
                      _reservations(s),
                      const SizedBox(height: 16),
                      _categories(s),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _activity(s),
        ],
      ),
    );
  }

  Widget _brand(DashboardCompany e) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: AppLogo(
              compact: true,
              color: Theme.of(context).colorScheme.onSurface,
              imageUrl: e.logoUrl,
              title: e.nombreComercial.isEmpty ? e.nombre : e.nombreComercial,
            ),
          ),
        ],
      ),
    ),
  );
  Widget _metric(String label, String value, IconData icon) {
    final accent = icon == Icons.payments || icon == Icons.trending_up
        ? const Color(0xFF28B779)
        : icon == Icons.people
        ? const Color(0xFFD88B43)
        : icon == Icons.car_rental
        ? const Color(0xFF9971E8)
        : const Color(0xFF649DEB);
    return Card(
      child: InkWell(
        onTap: () => _openQuickAction(switch (label) {
          "Reservas hoy" => const ReservacionesPage(soloHoy: true),
          "Vehículos alquilados" => const RentasPage(),
          "Clientes activos" => const ClientesPage(),
          _ => const PagosPage(),
        }),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(icon, color: accent, size: 18),
                ],
              ),
              const Spacer(),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                  letterSpacing: -.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reservations(DashboardSummary s) => _panel(
    'Reservas recientes',
    s.reservasRecientes.isEmpty
        ? [const Text('No hay reservaciones recientes.')]
        : s.reservasRecientes
              .map(
                (x) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: Text(x.vehiculo),
                  subtitle: Text(
                    '${x.cliente} · ${(x.periodoSinHora ? PeriodoAlquilerFechas.formato(x.fecha, true) : DateFormat('dd/MM hh:mm a').format(x.fecha))}',
                  ),
                  trailing: Chip(label: Text(x.estado)),
                ),
              )
              .toList(),
  );
  Widget _categories(DashboardSummary s) => _panel(
    'Vehículos por categoría',
    s.vehiculosPorCategoria.isEmpty
        ? [const Text('No hay vehículos activos.')]
        : s.vehiculosPorCategoria
              .map(
                (x) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(x.categoria),
                  subtitle: LinearProgressIndicator(value: x.porcentaje / 100),
                  trailing: Text(
                    '${x.cantidad} · ${x.porcentaje.toStringAsFixed(1)}%',
                  ),
                ),
              )
              .toList(),
  );
  Widget _activity(DashboardSummary s) => _panel(
    'Actividad reciente',
    s.actividadReciente.isEmpty
        ? [const Text('No hay actividad reciente.')]
        : s.actividadReciente
              .map(
                (x) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    x.tipo == 'PAGO'
                        ? Icons.payments_outlined
                        : x.tipo == 'RENTA'
                        ? Icons.key_outlined
                        : Icons.event_outlined,
                  ),
                  title: Text(x.titulo),
                  subtitle: Text(x.detalle),
                  trailing: Text(DateFormat('dd/MM hh:mm a').format(x.fecha)),
                ),
              )
              .toList(),
  );
  Widget _panel(String title, List<Widget> children) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ),
  );
  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }
}

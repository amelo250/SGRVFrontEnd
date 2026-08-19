import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: Drawer(child: _menu(s)),
      appBar: AppBar(
        title: Text(
          s?.empresa.nombreComercial.isNotEmpty == true
              ? s!.empresa.nombreComercial
              : 'Dashboard',
        ),
        actions: [
          IconButton(
            onPressed: () => p.load(refresh: true),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: DashboardQuickActionsFab(actions: _quickActions()),
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

  Widget _menu(DashboardSummary? s) => SafeArea(
    child: Column(
      children: [
        Container(
          color: const Color(0xFF081225),
          padding: const EdgeInsets.all(20),
          child: AppLogo(
            compact: true,
            imageUrl: s?.empresa.logoUrl,
            title: s?.empresa.nombreComercial.isNotEmpty == true
                ? s!.empresa.nombreComercial
                : 'SGRV',
          ),
        ),
        Expanded(
          child: ListView(
            children: _nav
                .map(
                  (x) => ListTile(
                    leading: Icon(x.icon),
                    title: Text(x.label),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => x.page),
                      );
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
  Widget _content(DashboardTaskProvider p, DashboardSummary? s) {
    if (s == null) {
      return const Center(child: Text('Sin información disponible.'));
    }
    final money = NumberFormat.currency(locale: 'es_DO', symbol: 'DOP ');
    return RefreshIndicator(
      onRefresh: () => p.load(refresh: true),
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          _brand(s.empresa),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (_, c) => GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: c.maxWidth >= 1000
                  ? 5
                  : c.maxWidth >= 620
                  ? 2
                  : 1,
              childAspectRatio: 2.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
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
          AppLogo(
            compact: true,
            color: const Color(0xFF172033),
            imageUrl: e.logoUrl,
            title: e.nombreComercial.isEmpty ? e.nombre : e.nombreComercial,
          ),
          const Spacer(),
          Text(
            'Empresa #${e.idEmpresa}',
            style: const TextStyle(color: Color(0xFF7B8498)),
          ),
        ],
      ),
    ),
  );
  Widget _metric(String label, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(child: Icon(icon)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
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
                    '${x.cliente} · ${DateFormat('dd/MM hh:mm a').format(x.fecha)}',
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
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
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

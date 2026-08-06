import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/pages/mantenimiento_form_page.dart';
import 'package:sgrv_frontend/features/mantenimientos/providers/mantenimiento_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class MantenimientosPage extends StatefulWidget {
  const MantenimientosPage({super.key});
  @override
  State<MantenimientosPage> createState() => _MantenimientosPageState();
}

class _MantenimientosPageState extends State<MantenimientosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MantenimientoProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MantenimientoProvider>();
    return AppModuleScaffold(
      title: 'Mantenimientos',
      subtitle: 'Historial, costos y alertas estimadas de la flotilla.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Registrar'),
      ),
      body: Column(
        children: [
          AppSearchPanel(
            hint: 'Vehículo, placa, tipo o taller',
            onChanged: (value) => provider.load(search: value),
          ),
          const SizedBox(height: 14),
          _Summary(provider: provider),
          const SizedBox(height: 14),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(MantenimientoProvider provider) {
    if (provider.status == MantenimientoStatus.loading ||
        provider.status == MantenimientoStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == MantenimientoStatus.error) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar los mantenimientos',
        message: provider.error,
        onRetry: provider.load,
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.load(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (provider.resumen?.alertas.isNotEmpty == true) ...[
            Text('Alertas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...provider.resumen!.alertas.map(
              (alerta) => Card(
                child: ListTile(
                  leading: Icon(
                    alerta.nivel == 'VENCIDO'
                        ? Icons.error_rounded
                        : Icons.warning_amber_rounded,
                    color: alerta.nivel == 'VENCIDO' ? Colors.red : Colors.orange,
                  ),
                  title: Text(alerta.vehiculo),
                  subtitle: Text(alerta.mensaje),
                  trailing: Text(alerta.nivel.replaceAll('_', ' ')),
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text('Historial', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (provider.items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(34),
                child: Center(child: Text('No hay mantenimientos registrados.')),
              ),
            )
          else
            ...provider.items.map(
              (item) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.build_rounded)),
                  title: Text('${item.tipoNombre} · ${item.vehiculo}'),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy').format(item.fecha)}'
                    '${item.kilometraje == null ? '' : ' · ${item.kilometraje} km'}',
                  ),
                  trailing: Text(
                    item.costo == null
                        ? '—'
                        : NumberFormat.currency(symbol: r'RD$ ').format(item.costo),
                  ),
                  onTap: () => _openForm(item),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openForm([Mantenimiento? item]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => MantenimientoFormPage(mantenimiento: item),
      ),
    );
    if (mounted) await context.read<MantenimientoProvider>().load(refresh: true);
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.provider});
  final MantenimientoProvider provider;
  @override
  Widget build(BuildContext context) {
    final value = provider.resumen;
    return Row(
      children: [
        _card(context, 'Registros', '${value?.totalRegistros ?? 0}', Colors.blue),
        const SizedBox(width: 10),
        _card(context, 'Próximos', '${value?.alertasProximas ?? 0}', Colors.orange),
        const SizedBox(width: 10),
        _card(context, 'Vencidos', '${value?.alertasVencidas ?? 0}', Colors.red),
      ],
    );
  }

  Widget _card(BuildContext context, String label, String value, Color color) =>
      Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

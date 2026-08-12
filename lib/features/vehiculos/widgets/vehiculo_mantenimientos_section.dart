import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/core/utils/money_formatter.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/pages/mantenimiento_form_page.dart';
import 'package:sgrv_frontend/features/mantenimientos/providers/mantenimiento_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

import '../models/vehiculo.dart';

class VehiculoMantenimientosSection extends StatefulWidget {
  const VehiculoMantenimientosSection({required this.vehiculo, super.key});

  final Vehiculo vehiculo;

  @override
  State<VehiculoMantenimientosSection> createState() =>
      _VehiculoMantenimientosSectionState();
}

class _VehiculoMantenimientosSectionState
    extends State<VehiculoMantenimientosSection> {
  late final MantenimientoProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = MantenimientoProvider();
    _load();
  }

  Future<void> _load({bool refresh = false}) =>
      _provider.load(idVehiculo: widget.vehiculo.idVehiculo, refresh: refresh);

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider.value(
    value: _provider,
    child: Consumer<MantenimientoProvider>(
      builder: (context, provider, _) => Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Historial de mantenimiento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('Servicios y costos registrados para este vehículo.'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: provider.saving ? null : () => _openForm(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar mantenimiento'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(child: _body(context, provider)),
        ],
      ),
    ),
  );

  Widget _body(BuildContext context, MantenimientoProvider provider) {
    if (provider.status == MantenimientoStatus.initial ||
        provider.status == MantenimientoStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == MantenimientoStatus.error) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo cargar el historial',
        message: provider.error,
        onRetry: _load,
      );
    }
    if (provider.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            Card(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: AppStateView(
                  icon: Icons.build_circle_outlined,
                  title: 'Sin mantenimientos registrados',
                  message:
                      'Agrega el primer mantenimiento desde esta pantalla.',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: provider.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = provider.items[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.build_rounded)),
              title: Text(item.tipoNombre),
              subtitle: Text(_details(item)),
              trailing: Text(
                MoneyFormatter.format(
                  item.costo ?? 0,
                  currencyCode: widget.vehiculo.monedaCodigo,
                  currencySymbol: widget.vehiculo.monedaSimbolo,
                ),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              onTap: () => _openForm(context, item),
            ),
          );
        },
      ),
    );
  }

  String _details(Mantenimiento item) {
    final parts = <String>[DateFormat('dd/MM/yyyy').format(item.fecha)];
    if (item.kilometraje != null) parts.add('${item.kilometraje} km');
    if (item.taller?.trim().isNotEmpty == true) parts.add(item.taller!.trim());
    if (item.observacion?.trim().isNotEmpty == true) {
      parts.add(item.observacion!.trim());
    }
    return parts.join(' · ');
  }

  Future<void> _openForm(
    BuildContext context, [
    Mantenimiento? mantenimiento,
  ]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _provider,
          child: MantenimientoFormPage(
            mantenimiento: mantenimiento,
            idVehiculo: widget.vehiculo.idVehiculo,
            vehiculoNombre:
                '${widget.vehiculo.marca} ${widget.vehiculo.modelo} '
                '(${widget.vehiculo.placa})',
          ),
        ),
      ),
    );
    if (mounted) await _load(refresh: true);
  }
}

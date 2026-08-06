import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/pages/vehiculo_form_page.dart';
import 'package:sgrv_frontend/features/vehiculos/pages/vehiculo_admin_page.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/widgets/vehiculo_card.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehicle_catalog_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/widgets/vehiculo_filter_panel.dart';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleCatalogProvider>().load();
      context.read<VehiculoProvider>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();
    final catalogs = context.watch<VehicleCatalogProvider>();
    return AppModuleScaffold(
      title: 'Vehículos',
      subtitle:
          'Controla disponibilidad, tarifas y características de la flota.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo vehículo'),
      ),
      body: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.directions_car_rounded,
                    color: Color(0xFF3867F4),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${provider.vehiculos.length} vehículos visibles',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  FilterChip(
                    avatar: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('Inactivos'),
                    selected: provider.incluirInactivos,
                    onSelected: provider.establecerIncluirInactivos,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          VehiculoFilterPanel(
            filter: provider.filter,
            types: catalogs.types,
            fuels: catalogs.fuels,
            brands: provider.marcas,
            onTypeChanged: provider.establecerTipo,
            onFuelChanged: provider.establecerCombustible,
            onBrandChanged: provider.establecerMarca,
            onClear: provider.limpiarFiltros,
          ),
          const SizedBox(height: 16),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(VehiculoProvider provider) => switch (provider.status) {
    VehiculoStatus.initial ||
    VehiculoStatus.loading => const Center(child: CircularProgressIndicator()),
    VehiculoStatus.error => AppStateView(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar la flota',
      message: provider.errorMessage,
      onRetry: provider.cargar,
    ),
    VehiculoStatus.empty => AppStateView(
      icon: Icons.directions_car_outlined,
      title: provider.tieneFiltros
          ? 'No hay vehículos con esos filtros'
          : 'No hay vehículos',
      message: provider.tieneFiltros
          ? 'Limpia o cambia los filtros para ampliar los resultados.'
          : 'Agrega el primer vehículo de tu flota.',
      onRetry: provider.tieneFiltros ? provider.limpiarFiltros : null,
    ),
    VehiculoStatus.success => RefreshIndicator(
      onRefresh: () => provider.cargar(refresh: true),
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 1050
                ? 3
                : constraints.maxWidth >= 650
                ? 2
                : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: constraints.maxWidth >= 650 ? .82 : 1.05,
          ),
          itemCount: provider.vehiculos.length,
          itemBuilder: (_, index) {
            final vehicle = provider.vehiculos[index];
            return VehiculoCard(
              vehiculo: vehicle,
              imageHeaders: provider.imageHeaders,
              onAdministrar: () => _openAdministration(vehicle),
              onEditar: () => _openForm(vehicle),
              onDesactivar: () => _confirmDeactivation(vehicle),
            );
          },
        ),
      ),
    ),
  };

  Future<void> _openForm([Vehiculo? vehicle]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => VehiculoFormPage(vehiculo: vehicle)),
    );
    if (mounted) await context.read<VehiculoProvider>().cargar(refresh: true);
  }

  Future<void> _openAdministration(Vehiculo vehicle) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => VehiculoAdminPage(vehiculo: vehicle)),
    );
    if (mounted) await context.read<VehiculoProvider>().cargar(refresh: true);
  }

  Future<void> _confirmDeactivation(Vehiculo vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Desactivar vehículo'),
        content: Text('¿Deseas desactivar ${vehicle.marca} ${vehicle.modelo}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = context.read<VehiculoProvider>();
    final success = await provider.desactivar(vehicle.idVehiculo);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'No fue posible desactivar el vehículo.',
        ),
      ),
    );
  }
}

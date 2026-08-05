import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/pages/vehiculo_form_page.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/widgets/vehiculo_card.dart';

class VehiculosPage extends StatefulWidget {
  const VehiculosPage({super.key});

  @override
  State<VehiculosPage> createState() => _VehiculosPageState();
}

class _VehiculosPageState extends State<VehiculosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<VehiculoProvider>().cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehículos'),
        actions: [
          FilterChip(
            label: const Text('Incluir inactivos'),
            selected: provider.incluirInactivos,
            onSelected: provider.establecerIncluirInactivos,
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo vehículo'),
      ),
      body: switch (provider.status) {
        VehiculoStatus.initial || VehiculoStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
        VehiculoStatus.error => _ErrorState(
          message: provider.errorMessage ?? 'No fue posible cargar.',
          onRetry: provider.cargar,
        ),
        VehiculoStatus.empty => RefreshIndicator(
          onRefresh: () => provider.cargar(refresh: true),
          child: const CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                child: Center(child: Text('No hay vehículos registrados.')),
              ),
            ],
          ),
        ),
        VehiculoStatus.success => RefreshIndicator(
          onRefresh: () => provider.cargar(refresh: true),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: provider.vehiculos.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final vehicle = provider.vehiculos[index];
              return VehiculoCard(
                vehiculo: vehicle,
                onEditar: () => _abrirFormulario(context, vehicle),
                onDesactivar: () => _confirmarDesactivacion(context, vehicle),
              );
            },
          ),
        ),
      },
    );
  }

  Future<void> _abrirFormulario(BuildContext context, [Vehiculo? vehicle]) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => VehiculoFormPage(vehiculo: vehicle)),
    );
  }

  Future<void> _confirmarDesactivacion(
    BuildContext context,
    Vehiculo vehicle,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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

    if (confirmed != true || !context.mounted) return;
    final success = await context.read<VehiculoProvider>().desactivar(
      vehicle.idVehiculo,
    );
    if (!context.mounted || success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<VehiculoProvider>().errorMessage ??
              'No fue posible desactivar el vehículo.',
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

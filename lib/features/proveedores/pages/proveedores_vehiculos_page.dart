import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';
import 'package:sgrv_frontend/features/proveedores/pages/proveedor_vehiculo_form_page.dart';
import 'package:sgrv_frontend/features/proveedores/providers/proveedor_vehiculo_provider.dart';
import 'package:sgrv_frontend/features/proveedores/widgets/proveedor_vehiculo_card.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class ProveedoresVehiculosPage extends StatefulWidget {
  const ProveedoresVehiculosPage({super.key});

  @override
  State<ProveedoresVehiculosPage> createState() =>
      _ProveedoresVehiculosPageState();
}

class _ProveedoresVehiculosPageState extends State<ProveedoresVehiculosPage> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProveedorVehiculoProvider>().cargar(),
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProveedorVehiculoProvider>();
    return AppModuleScaffold(
      title: 'Proveedores',
      subtitle: 'Gestiona propietarios terceros y aliados de la flota.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Nuevo proveedor'),
      ),
      body: Column(
        children: [
          AppSearchPanel(
            controller: _search,
            hint: 'Nombre, RNC o cédula',
            onChanged: (_) {},
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed: () => provider.cargar(busqueda: _search.text),
                  icon: const Icon(Icons.search_rounded),
                  tooltip: 'Buscar',
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactivos'),
                  selected: provider.incluirInactivos,
                  onSelected: provider.establecerIncluirInactivos,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(ProveedorVehiculoProvider provider) {
    if (provider.status == ProveedorStatus.initial ||
        provider.status == ProveedorStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == ProveedorStatus.error) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar los proveedores',
        message: provider.errorMessage,
        onRetry: provider.cargar,
      );
    }
    if (provider.proveedores.isEmpty) {
      return const AppStateView(
        icon: Icons.handshake_outlined,
        title: 'No hay proveedores',
        message: 'Registra tu primer aliado de vehículos.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.cargar(busqueda: _search.text, refresh: true),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: provider.proveedores.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) {
          final supplier = provider.proveedores[index];
          return ProveedorVehiculoCard(
            proveedor: supplier,
            onEditar: () => _openForm(supplier),
            onDesactivar: () => _deactivate(supplier),
          );
        },
      ),
    );
  }

  Future<void> _openForm([ProveedorVehiculo? supplier]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProveedorVehiculoFormPage(proveedor: supplier),
      ),
    );
    if (mounted)
      await context.read<ProveedorVehiculoProvider>().cargar(refresh: true);
  }

  Future<void> _deactivate(ProveedorVehiculo supplier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Desactivar proveedor'),
        content: Text('¿Deseas desactivar a ${supplier.nombre}?'),
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
    final provider = context.read<ProveedorVehiculoProvider>();
    final success = await provider.desactivar(supplier.idProveedorVehiculo);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'No fue posible completar la operación.',
        ),
      ),
    );
  }
}

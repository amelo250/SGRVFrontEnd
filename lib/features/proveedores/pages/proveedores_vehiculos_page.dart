import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';
import 'package:sgrv_frontend/features/proveedores/pages/proveedor_vehiculo_form_page.dart';
import 'package:sgrv_frontend/features/proveedores/providers/proveedor_vehiculo_provider.dart';
import 'package:sgrv_frontend/features/proveedores/widgets/proveedor_vehiculo_card.dart';

class ProveedoresVehiculosPage extends StatefulWidget {
  const ProveedoresVehiculosPage({super.key});

  @override
  State<ProveedoresVehiculosPage> createState() =>
      _ProveedoresVehiculosPageState();
}

class _ProveedoresVehiculosPageState extends State<ProveedoresVehiculosPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ProveedorVehiculoProvider>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProveedorVehiculoProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Proveedores de vehículos')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(context),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo proveedor'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    controller: _searchController,
                    hintText: 'Buscar por nombre o RNC/cédula',
                    leading: const Icon(Icons.search),
                    onSubmitted: (value) => provider.cargar(busqueda: value),
                    trailing: [
                      IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: () {
                          _searchController.clear();
                          provider.cargar();
                        },
                        icon: const Icon(Icons.clear),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Inactivos'),
                  selected: provider.incluirInactivos,
                  onSelected: provider.establecerIncluirInactivos,
                ),
              ],
            ),
          ),
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
      return Center(
        child: FilledButton.icon(
          onPressed: provider.cargar,
          icon: const Icon(Icons.refresh),
          label: Text(provider.errorMessage ?? 'Reintentar'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () =>
          provider.cargar(busqueda: _searchController.text, refresh: true),
      child: provider.proveedores.isEmpty
          ? const CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  child: Center(child: Text('No hay proveedores registrados.')),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: provider.proveedores.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final proveedor = provider.proveedores[index];
                return ProveedorVehiculoCard(
                  proveedor: proveedor,
                  onEditar: () => _abrirFormulario(context, proveedor),
                  onDesactivar: () => _desactivar(context, proveedor),
                );
              },
            ),
    );
  }

  Future<void> _abrirFormulario(
    BuildContext context, [
    ProveedorVehiculo? proveedor,
  ]) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ProveedorVehiculoFormPage(proveedor: proveedor),
      ),
    );
  }

  Future<void> _desactivar(
    BuildContext context,
    ProveedorVehiculo proveedor,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Desactivar proveedor'),
        content: Text('¿Deseas desactivar a ${proveedor.nombre}?'),
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
    final provider = context.read<ProveedorVehiculoProvider>();
    final success = await provider.desactivar(proveedor.idProveedorVehiculo);
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(provider.errorMessage ?? 'Operación fallida.')),
    );
  }
}

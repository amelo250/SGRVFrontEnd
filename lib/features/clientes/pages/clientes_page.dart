import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';
import 'package:sgrv_frontend/features/clientes/pages/cliente_form_page.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/clientes/widgets/cliente_card.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ClienteProvider>().cargar(),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: const Text('Incluir inactivos'),
              selected: provider.incluirInactivos,
              onSelected: provider.establecerIncluirInactivos,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : () => _abrirFormulario(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Nuevo cliente'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar cliente',
                hintText: 'Nombre, documento, correo o teléfono',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (provider.status == ClienteStatus.success)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${provider.totalCount} clientes encontrados',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(ClienteProvider provider) {
    return switch (provider.status) {
      ClienteStatus.initial ||
      ClienteStatus.loading => const Center(child: CircularProgressIndicator()),
      ClienteStatus.error => _ErrorState(
        message: provider.errorMessage ?? 'No fue posible cargar.',
        onRetry: provider.cargar,
      ),
      ClienteStatus.empty => RefreshIndicator(
        onRefresh: () => provider.cargar(refresh: true),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(child: Text('No hay clientes para mostrar.')),
            ),
          ],
        ),
      ),
      ClienteStatus.success => Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.cargar(refresh: true),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: provider.clientes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final cliente = provider.clientes[index];
                  return ClienteCard(
                    cliente: cliente,
                    onEditar: () => _abrirFormulario(context, cliente),
                    onDesactivar: () =>
                        _confirmarEstado(cliente, restaurar: false),
                    onRestaurar: () =>
                        _confirmarEstado(cliente, restaurar: true),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: provider.hasPreviousPage
                        ? provider.paginaAnterior
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Página ${provider.pageNumber} de '
                    '${provider.totalPages}',
                  ),
                  IconButton(
                    onPressed: provider.hasNextPage
                        ? provider.paginaSiguiente
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    };
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ClienteProvider>().buscar(value);
    });
  }

  Future<void> _abrirFormulario(BuildContext context, [Cliente? cliente]) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: cliente)),
    );
  }

  Future<void> _confirmarEstado(
    Cliente cliente, {
    required bool restaurar,
  }) async {
    final verb = restaurar ? 'restaurar' : 'desactivar';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${restaurar ? 'Restaurar' : 'Desactivar'} cliente'),
        content: Text('¿Deseas $verb a ${cliente.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(restaurar ? 'Restaurar' : 'Desactivar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = context.read<ClienteProvider>();
    final success = restaurar
        ? await provider.restaurar(cliente.idCliente)
        : await provider.desactivar(cliente.idCliente);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'No fue posible completar la acción.',
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

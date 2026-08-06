import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';
import 'package:sgrv_frontend/features/clientes/pages/cliente_form_page.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/clientes/widgets/cliente_card.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

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
    return AppModuleScaffold(
      title: 'Clientes',
      subtitle: 'Administra perfiles, documentos y licencias de tus clientes.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nuevo cliente'),
      ),
      body: Column(
        children: [
          AppSearchPanel(
            hint: 'Nombre, documento, correo o teléfono',
            onChanged: _onSearchChanged,
            trailing: FilterChip(
              avatar: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Inactivos'),
              selected: provider.incluirInactivos,
              onSelected: provider.establecerIncluirInactivos,
            ),
          ),
          const SizedBox(height: 14),
          if (provider.status == ClienteStatus.success)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${provider.totalCount} clientes encontrados',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 10),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(ClienteProvider provider) => switch (provider.status) {
    ClienteStatus.initial ||
    ClienteStatus.loading => const Center(child: CircularProgressIndicator()),
    ClienteStatus.error => AppStateView(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar los clientes',
      message: provider.errorMessage,
      onRetry: provider.cargar,
    ),
    ClienteStatus.empty => AppStateView(
      icon: Icons.people_outline_rounded,
      title: 'No hay clientes',
      message: 'Registra tu primer cliente para comenzar.',
    ),
    ClienteStatus.success => Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.cargar(refresh: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: provider.clientes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final client = provider.clientes[index];
                return ClienteCard(
                  cliente: client,
                  onEditar: () => _openForm(client),
                  onDesactivar: () => _confirmStatus(client, restore: false),
                  onRestaurar: () => _confirmStatus(client, restore: true),
                );
              },
            ),
          ),
        ),
        AppPagination(
          page: provider.pageNumber,
          totalPages: provider.totalPages,
          onPrevious: provider.hasPreviousPage ? provider.paginaAnterior : null,
          onNext: provider.hasNextPage ? provider.paginaSiguiente : null,
        ),
      ],
    ),
  };

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ClienteProvider>().buscar(value);
    });
  }

  Future<void> _openForm([Cliente? client]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => ClienteFormPage(cliente: client)),
    );
    if (mounted) await context.read<ClienteProvider>().cargar(refresh: true);
  }

  Future<void> _confirmStatus(Cliente client, {required bool restore}) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(restore ? Icons.restore_rounded : Icons.person_off_outlined),
        title: Text('${restore ? 'Restaurar' : 'Desactivar'} cliente'),
        content: Text(
          '¿Deseas ${restore ? 'restaurar' : 'desactivar'} a ${client.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(restore ? 'Restaurar' : 'Desactivar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final provider = context.read<ClienteProvider>();
    final success = restore
        ? await provider.restaurar(client.idCliente)
        : await provider.desactivar(client.idCliente);
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

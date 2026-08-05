import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/pages/reservacion_form_page.dart';
import 'package:sgrv_frontend/features/reservaciones/providers/reservacion_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/widgets/reservacion_card.dart';

class ReservacionesPage extends StatefulWidget {
  const ReservacionesPage({super.key});

  @override
  State<ReservacionesPage> createState() => _ReservacionesPageState();
}

class _ReservacionesPageState extends State<ReservacionesPage> {
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReservacionProvider>().load(),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservacionProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Reservaciones')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : () => _openForm(context),
        icon: const Icon(Icons.event_available),
        label: const Text('Nueva reservación'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                labelText: 'Buscar reservación',
                hintText: 'Cliente, vehículo o estado',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          if (provider.status == ReservacionStatus.success)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '${provider.totalCount} reservaciones encontradas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Expanded(child: _buildBody(provider)),
        ],
      ),
    );
  }

  Widget _buildBody(ReservacionProvider provider) {
    return switch (provider.status) {
      ReservacionStatus.initial || ReservacionStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      ReservacionStatus.error => _ErrorState(
        message: provider.errorMessage ?? 'No fue posible cargar.',
        onRetry: provider.load,
      ),
      ReservacionStatus.empty => RefreshIndicator(
        onRefresh: () => provider.load(refresh: true),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(child: Text('No hay reservaciones para mostrar.')),
            ),
          ],
        ),
      ),
      ReservacionStatus.success => Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.load(refresh: true),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: provider.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final item = provider.items[index];
                  return ReservacionCard(
                    reservacion: item,
                    onEdit: () => _openForm(context, item),
                    onConfirm: () => _confirmAction(item, confirm: true),
                    onCancel: () => _confirmAction(item, confirm: false),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: provider.hasPreviousPage
                      ? provider.previousPage
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  'Página ${provider.pageNumber} de '
                  '${provider.totalPages}',
                ),
                IconButton(
                  onPressed: provider.hasNextPage ? provider.nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ],
      ),
    };
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ReservacionProvider>().search(value);
    });
  }

  Future<void> _openForm(BuildContext context, [Reservacion? reservacion]) {
    return Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ReservacionFormPage(reservacion: reservacion),
      ),
    );
  }

  Future<void> _confirmAction(
    Reservacion reservacion, {
    required bool confirm,
  }) async {
    final action = confirm ? 'confirmar' : 'cancelar';
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${confirm ? 'Confirmar' : 'Cancelar'} reservación'),
        content: Text(
          '¿Deseas $action la reservación de '
          '${reservacion.clienteNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(confirm ? 'Confirmar' : 'Cancelar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final provider = context.read<ReservacionProvider>();
    final success = confirm
        ? await provider.confirm(reservacion.idReservacion)
        : await provider.cancel(reservacion.idReservacion);
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/pages/reservacion_form_page.dart';
import 'package:sgrv_frontend/features/reservaciones/providers/reservacion_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/widgets/reservacion_card.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class ReservacionesPage extends StatefulWidget {
  const ReservacionesPage({super.key});

  @override
  State<ReservacionesPage> createState() => _ReservacionesPageState();
}

class _ReservacionesPageState extends State<ReservacionesPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ReservacionProvider>().load(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReservacionProvider>();
    return AppModuleScaffold(
      title: 'Reservaciones',
      subtitle: 'Organiza solicitudes, confirmaciones y disponibilidad futura.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : () => _openForm(),
        icon: const Icon(Icons.event_available_rounded),
        label: const Text('Nueva reservación'),
      ),
      body: Column(
        children: [
          AppSearchPanel(
            hint: 'Cliente, vehículo o estado',
            onChanged: _search,
          ),
          const SizedBox(height: 14),
          if (provider.status == ReservacionStatus.success)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${provider.totalCount} reservaciones encontradas',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 10),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(ReservacionProvider provider) => switch (provider.status) {
    ReservacionStatus.initial || ReservacionStatus.loading => const Center(
      child: CircularProgressIndicator(),
    ),
    ReservacionStatus.error => AppStateView(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar las reservaciones',
      message: provider.errorMessage,
      onRetry: provider.load,
    ),
    ReservacionStatus.empty => const AppStateView(
      icon: Icons.event_busy_outlined,
      title: 'No hay reservaciones',
      message: 'Crea una reservación para comenzar.',
    ),
    ReservacionStatus.success => Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.load(refresh: true),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: provider.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = provider.items[index];
                return ReservacionCard(
                  reservacion: item,
                  onEdit: () => _openForm(item),
                  onConfirm: () => _confirm(item, confirm: true),
                  onCancel: () => _confirm(item, confirm: false),
                );
              },
            ),
          ),
        ),
        AppPagination(
          page: provider.pageNumber,
          totalPages: provider.totalPages,
          onPrevious: provider.hasPreviousPage ? provider.previousPage : null,
          onNext: provider.hasNextPage ? provider.nextPage : null,
        ),
      ],
    ),
  };

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<ReservacionProvider>().search(value);
    });
  }

  Future<void> _openForm([Reservacion? reservation]) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ReservacionFormPage(reservacion: reservation),
      ),
    );
    if (mounted) await context.read<ReservacionProvider>().load(refresh: true);
  }

  Future<void> _confirm(
    Reservacion reservation, {
    required bool confirm,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          confirm ? Icons.event_available_rounded : Icons.event_busy_outlined,
        ),
        title: Text('${confirm ? 'Confirmar' : 'Cancelar'} reservación'),
        content: Text(
          '¿Deseas ${confirm ? 'confirmar' : 'cancelar'} la reservación de ${reservation.clienteNombre}?',
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
        ? await provider.confirm(reservation.idReservacion)
        : await provider.cancel(reservation.idReservacion);
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

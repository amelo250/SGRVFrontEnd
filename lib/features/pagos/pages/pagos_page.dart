import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_detail_page.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_form_page.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_provider.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_card.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class PagosPage extends StatefulWidget {
  const PagosPage({super.key});

  @override
  State<PagosPage> createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<PagoProvider>().load(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PagoProvider>();
    return AppModuleScaffold(
      title: 'Pagos y cobros',
      subtitle: 'Controla ingresos, balances y comprobantes de cada renta.',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : _create,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Registrar pago'),
      ),
      body: Column(
        children: [
          AppSearchPanel(
            hint: 'Referencia u observaciones',
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(
                const Duration(milliseconds: 450),
                () => provider.search(value),
              );
            },
            trailing: Chip(
              avatar: const Icon(Icons.receipt_long_outlined, size: 18),
              label: Text('${provider.totalCount} pagos'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(PagoProvider provider) => switch (provider.status) {
    PagoStatus.initial ||
    PagoStatus.loading => const Center(child: CircularProgressIndicator()),
    PagoStatus.empty => const AppStateView(
      icon: Icons.receipt_long_outlined,
      title: 'Todavía no hay pagos',
      message: 'Registra el primer cobro de una renta.',
    ),
    PagoStatus.error => AppStateView(
      icon: Icons.cloud_off_rounded,
      title: 'No pudimos cargar los pagos',
      message: provider.errorMessage,
      onRetry: provider.load,
    ),
    PagoStatus.success => Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.load(refresh: true),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: provider.items.length,
              itemBuilder: (_, index) {
                final payment = provider.items[index];
                return PagoCard(
                  pago: payment,
                  onTap: () => _open(payment.idPago),
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

  Future<void> _create() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PagoFormPage()),
    );
    if (created == true && mounted) {
      await context.read<PagoProvider>().load(refresh: true);
    }
  }

  Future<void> _open(int id) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => PagoDetailPage(pagoId: id)),
    );
    if (mounted) await context.read<PagoProvider>().load(refresh: true);
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_detail_page.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_form_page.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_provider.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_card.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Pagos y cobros'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.isMutating ? null : _create,
        icon: const Icon(Icons.add_card_rounded),
        label: const Text('Registrar pago'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Control de cobros',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${provider.totalCount} pagos registrados',
                      style: const TextStyle(color: Color(0xFF747E92)),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar por referencia u observaciones',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 450),
                          () => provider.search(value),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _body(provider),
                    if (provider.status == PagoStatus.success) _pager(provider),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(PagoProvider provider) => switch (provider.status) {
    PagoStatus.initial || PagoStatus.loading => const Center(
      child: Padding(
        padding: EdgeInsets.all(70),
        child: CircularProgressIndicator(),
      ),
    ),
    PagoStatus.empty => _message(
      Icons.receipt_long_outlined,
      'Todavía no hay pagos registrados.',
    ),
    PagoStatus.error => _message(
      Icons.cloud_off_outlined,
      provider.errorMessage ?? 'No fue posible cargar los pagos.',
      retry: provider.load,
    ),
    PagoStatus.success => Column(
      children: provider.items
          .map((item) => PagoCard(pago: item, onTap: () => _open(item.idPago)))
          .toList(growable: false),
    ),
  };

  Widget _message(
    IconData icon,
    String text, {
    Future<void> Function()? retry,
  }) => Padding(
    padding: const EdgeInsets.all(70),
    child: Column(
      children: [
        Icon(icon, size: 54, color: const Color(0xFF67738A)),
        const SizedBox(height: 14),
        Text(text, textAlign: TextAlign.center),
        if (retry != null) ...[
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ],
    ),
  );

  Widget _pager(PagoProvider provider) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        onPressed: provider.hasPreviousPage ? provider.previousPage : null,
        icon: const Icon(Icons.chevron_left),
      ),
      Text('Página ${provider.pageNumber} de ${provider.totalPages}'),
      IconButton(
        onPressed: provider.hasNextPage ? provider.nextPage : null,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );

  Future<void> _create() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PagoFormPage()),
    );
    if (created == true && mounted)
      await context.read<PagoProvider>().load(refresh: true);
  }

  Future<void> _open(int id) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => PagoDetailPage(pagoId: id)),
    );
    if (mounted) await context.read<PagoProvider>().load(refresh: true);
  }
}

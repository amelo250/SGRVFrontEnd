import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../providers/gasto_provider.dart';
import '../widgets/gasto_card.dart';
import '../widgets/gasto_summary_cards.dart';
import 'gasto_detail_page.dart';
import 'gasto_form_page.dart';

class GastosPage extends StatefulWidget {
  const GastosPage({super.key});
  @override
  State<GastosPage> createState() => _GastosPageState();
}

class _GastosPageState extends State<GastosPage> {
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<GastoProvider>().load(),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 450),
      () => context.read<GastoProvider>().search(value),
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<GastoProvider>(
    builder: (context, provider, _) => AppModuleScaffold(
      title: 'Gastos',
      subtitle:
          '${provider.summaryData?.cantidad ?? provider.total} gastos totales registrados',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GastoFormPage()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nuevo gasto'),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(refresh: true),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GastoSummaryCards(summary: provider.summaryData),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
            SliverToBoxAdapter(
              child: AppSearchPanel(
                hint: 'Buscar por concepto, proveedor o comprobante',
                onChanged: _search,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            if (provider.status == GastoStatus.loading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.status == GastoStatus.error)
              SliverFillRemaining(
                child: AppStateView(
                  icon: Icons.cloud_off_rounded,
                  title: 'No fue posible cargar los gastos',
                  message: provider.error,
                  onRetry: provider.load,
                ),
              )
            else if (provider.status == GastoStatus.empty)
              SliverFillRemaining(
                child: AppStateView(
                  icon: Icons.receipt_long_rounded,
                  title: 'Aún no hay gastos',
                  message: 'Registra el primer gasto operativo.',
                ),
              )
            else
              SliverList.builder(
                itemCount: provider.items.length,
                itemBuilder: (context, index) {
                  final gasto = provider.items[index];
                  return GastoCard(
                    gasto: gasto,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GastoDetailPage(gasto: gasto),
                      ),
                    ),
                  );
                },
              ),
            SliverToBoxAdapter(
              child: AppPagination(
                page: provider.page,
                totalPages: provider.totalPages,
                onPrevious: provider.page > 1 ? provider.previousPage : null,
                onNext: provider.page < provider.totalPages
                    ? provider.nextPage
                    : null,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    ),
  );
}

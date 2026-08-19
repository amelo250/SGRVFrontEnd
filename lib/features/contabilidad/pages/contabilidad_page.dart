import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../providers/contabilidad_provider.dart';
import '../services/contabilidad_pdf_service.dart';

class ContabilidadPage extends StatefulWidget {
  const ContabilidadPage({super.key});
  @override
  State<ContabilidadPage> createState() => _ContabilidadPageState();
}

class _ContabilidadPageState extends State<ContabilidadPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ContabilidadProvider>().load(),
    );
  }

  Future<void> _range(ContabilidadProvider p) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: p.desde != null && p.hasta != null
          ? DateTimeRange(start: p.desde!, end: p.hasta!)
          : null,
    );
    if (result != null) await p.setDates(result.start, result.end);
  }

  Future<void> _export(ContabilidadProvider p) async {
    final data = p.data;
    if (data == null) return;
    final bytes = await ContabilidadPdfService().generate(
      data,
      desde: p.desde,
      hasta: p.hasta,
    );
    await Printing.layoutPdf(
      name: 'reporte-contabilidad.pdf',
      onLayout: (_) => bytes,
    );
  }

  @override
  Widget build(BuildContext context) => Consumer<ContabilidadProvider>(
    builder: (context, p, _) {
      final data = p.data;
      final money = NumberFormat.currency(locale: 'es_DO', symbol: r'RD$');
      final categories = <String, String>{
        for (final x in data?.categorias ?? const []) x.codigo: x.nombre,
      };
      return AppModuleScaffold(
        title: 'Contabilidad',
        subtitle: 'Indicadores de ingresos, gastos y rentabilidad',
        floatingActionButton: FloatingActionButton.extended(
          onPressed: data == null ? null : () => _export(p),
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text('Exportar reporte'),
        ),
        body: p.loading && data == null
            ? const Center(child: CircularProgressIndicator())
            : p.error != null && data == null
            ? AppStateView(
                icon: Icons.error_outline,
                title: 'No fue posible cargar contabilidad',
                message: p.error,
                onRetry: p.load,
              )
            : RefreshIndicator(
                onRefresh: p.load,
                child: ListView(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(
                                  value: 'TODOS',
                                  label: Text('Todos'),
                                ),
                                ButtonSegment(
                                  value: 'INGRESO',
                                  label: Text('Ingresos'),
                                ),
                                ButtonSegment(
                                  value: 'GASTO',
                                  label: Text('Gastos'),
                                ),
                              ],
                              selected: {p.tipo},
                              onSelectionChanged: (v) => p.setType(v.first),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.date_range, size: 18),
                              label: Text(
                                p.desde == null
                                    ? 'Todos los períodos'
                                    : '${DateFormat('dd/MM/yy').format(p.desde!)} - ${DateFormat('dd/MM/yy').format(p.hasta!)}',
                              ),
                              onPressed: () => _range(p),
                            ),
                            ActionChip(
                              label: const Text('Este mes'),
                              onPressed: () {
                                final n = DateTime.now();
                                p.setDates(
                                  DateTime(n.year, n.month),
                                  DateTime(
                                    n.year,
                                    n.month + 1,
                                  ).subtract(const Duration(days: 1)),
                                );
                              },
                            ),
                            ActionChip(
                              label: const Text('Este año'),
                              onPressed: () {
                                final y = DateTime.now().year;
                                p.setDates(DateTime(y), DateTime(y, 12, 31));
                              },
                            ),
                            DropdownButton<String>(
                              value: categories.containsKey(p.categoria)
                                  ? p.categoria
                                  : 'TODAS',
                              items: [
                                const DropdownMenuItem(
                                  value: 'TODAS',
                                  child: Text('Todas las categorías'),
                                ),
                                ...categories.entries.map(
                                  (x) => DropdownMenuItem(
                                    value: x.key,
                                    child: Text(x.value),
                                  ),
                                ),
                              ],
                              onChanged: (v) {
                                if (v != null) p.setCategory(v);
                              },
                            ),
                            if (p.desde != null)
                              IconButton(
                                tooltip: 'Limpiar período',
                                onPressed: () => p.setDates(null, null),
                                icon: const Icon(Icons.filter_alt_off),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _metric(
                          'Ingresos',
                          money.format(data?.ingresos ?? 0),
                          Icons.trending_up,
                          Colors.green,
                        ),
                        _metric(
                          'Gastos',
                          money.format(data?.gastos ?? 0),
                          Icons.trending_down,
                          Colors.red,
                        ),
                        _metric(
                          'Resultado neto',
                          money.format(data?.resultadoNeto ?? 0),
                          Icons.account_balance_wallet,
                          Colors.blue,
                        ),
                        _metric(
                          'Margen',
                          '${(data?.margenPorcentaje ?? 0).toStringAsFixed(1)}%',
                          Icons.percent,
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Totales por categoría',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            for (final x in data?.categorias ?? const [])
                              ListTile(
                                leading: Icon(
                                  x.tipo == 'INGRESO'
                                      ? Icons.add_circle
                                      : Icons.remove_circle,
                                  color: x.tipo == 'INGRESO'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(x.nombre),
                                subtitle: Text('${x.cantidad} movimientos'),
                                trailing: Text(
                                  money.format(x.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Movimientos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final x in data?.movimientos ?? const [])
                              ListTile(
                                dense: true,
                                leading: Icon(
                                  x.tipo == 'INGRESO'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: x.tipo == 'INGRESO'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                title: Text(x.concepto),
                                subtitle: Text(
                                  '${DateFormat('dd/MM/yyyy').format(x.fecha)} · ${x.categoriaNombre} · ${x.referencia}',
                                ),
                                trailing: Text(money.format(x.monto)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      );
    },
  );
  Widget _metric(String label, String value, IconData icon, Color color) =>
      SizedBox(
        width: 250,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: .12),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_provider.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_status_chip.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_summary_card.dart';

class PagoDetailPage extends StatefulWidget {
  const PagoDetailPage({required this.pagoId, super.key});
  final int pagoId;

  @override
  State<PagoDetailPage> createState() => _PagoDetailPageState();
}

class _PagoDetailPageState extends State<PagoDetailPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<PagoProvider>().loadDetail(widget.pagoId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PagoProvider>();
    final pago = provider.selected;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Pago #${widget.pagoId}'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : pago == null || pago.idPago != widget.pagoId
          ? Center(
              child: Text(
                provider.errorMessage ?? 'No fue posible cargar el pago.',
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 27,
                                      backgroundColor: Color(0xFFEAF0FF),
                                      child: Icon(
                                        Icons.payments_rounded,
                                        color: Color(0xFF3867F4),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pago.clienteNombre,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                          Text(
                                            pago.vehiculoDescripcion,
                                            style: const TextStyle(
                                              color: Color(0xFF747E92),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PagoStatusChip(
                                      code: pago.estadoCodigo,
                                      label: pago.estadoNombre,
                                      active: pago.activo,
                                    ),
                                  ],
                                ),
                                const Divider(height: 34),
                                _row('Renta', '#${pago.idRenta}'),
                                _row(
                                  'Monto',
                                  '${pago.simboloMoneda} ${pago.monto.toStringAsFixed(2)}',
                                ),
                                _row(
                                  'Monto local',
                                  'RD\$ ${pago.montoMonedaLocal.toStringAsFixed(2)}',
                                ),
                                _row(
                                  'Tasa aplicada',
                                  pago.tasaCambioAplicada.toStringAsFixed(6),
                                ),
                                _row('Método', pago.metodoPagoNombre),
                                _row(
                                  'Fecha',
                                  DateFormat(
                                    'dd/MM/yyyy · hh:mm a',
                                  ).format(pago.fechaPago),
                                ),
                                if (pago.referencia != null)
                                  _row('Referencia', pago.referencia!),
                                if (pago.observaciones != null)
                                  _row('Observaciones', pago.observaciones!),
                                const SizedBox(height: 18),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: pago.activo
                                      ? OutlinedButton.icon(
                                          onPressed: provider.isMutating
                                              ? null
                                              : _void,
                                          icon: const Icon(Icons.block),
                                          label: const Text('Anular pago'),
                                        )
                                      : FilledButton.icon(
                                          onPressed: provider.isMutating
                                              ? null
                                              : _restore,
                                          icon: const Icon(Icons.restore),
                                          label: const Text('Restaurar'),
                                        ),
                                ),
                              ],
                            ),
                          ),
                          if (provider.summary != null) ...[
                            const SizedBox(height: 18),
                            PagoSummaryCard(summary: provider.summary!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(color: Color(0xFF747E92))),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Future<void> _void() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Anular pago'),
        content: const Text(
          'El monto dejará de aplicarse al balance de la renta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final ok = await context.read<PagoProvider>().voidPayment(widget.pagoId);
    if (ok && mounted) await _load();
  }

  Future<void> _restore() async {
    final ok = await context.read<PagoProvider>().restore(widget.pagoId);
    if (ok && mounted) await _load();
  }
}

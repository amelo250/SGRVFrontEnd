import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_form_page.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_financial_summary.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_status_chip.dart';
import 'package:sgrv_frontend/features/pagos/pages/pago_form_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_entrega_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_recepcion_page.dart';

class RentaDetailPage extends StatefulWidget {
  const RentaDetailPage({required this.rentaId, super.key});

  final int rentaId;

  @override
  State<RentaDetailPage> createState() => _RentaDetailPageState();
}

class _RentaDetailPageState extends State<RentaDetailPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await context.read<RentaProvider>().loadDetail(widget.rentaId);
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentaProvider>();
    final rental = provider.selected;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text('Renta #${widget.rentaId}'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : rental == null || rental.idRenta != widget.rentaId
          ? _error(provider)
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        children: [
                          _hero(context, provider),
                          const SizedBox(height: 18),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final details = _details(context, provider);
                              final summary = provider.summary == null
                                  ? const SizedBox.shrink()
                                  : RentaFinancialSummary(
                                      summary: provider.summary!,
                                    );
                              return constraints.maxWidth >= 800
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 6, child: details),
                                        const SizedBox(width: 18),
                                        Expanded(flex: 4, child: summary),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        details,
                                        const SizedBox(height: 18),
                                        summary,
                                      ],
                                    );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _hero(BuildContext context, RentaProvider provider) {
    final rental = provider.selected!;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173C9B), Color(0xFF5E55D8)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        runSpacing: 18,
        spacing: 18,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Color(0x33FFFFFF),
            child: Icon(Icons.key_rounded, color: Colors.white, size: 30),
          ),
          SizedBox(
            width: 430,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rental.clienteNombre,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rental.vehiculoDescripcion,
                  style: const TextStyle(color: Color(0xFFDDE5FF)),
                ),
              ],
            ),
          ),
          RentaStatusChip(
            code: rental.estadoCodigo,
            label: rental.estadoNombre,
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            onPressed: _openDelivery,
            icon: const Icon(Icons.assignment_outlined),
            label: const Text('Entrega y firmas'),
          ),
          if (rental.finalizada)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: _openReception,
              icon: const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Documento de recepción'),
            ),
          if (rental.activa)
            FilledButton.icon(
              onPressed: provider.isMutating ? null : _registerPayment,
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Registrar pago'),
            ),
          if (rental.puedeEditar)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: provider.isMutating ? null : _edit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          if (rental.puedeFinalizar)
            FilledButton.icon(
              onPressed: provider.isMutating ? null : _complete,
              icon: const Icon(Icons.assignment_turned_in_outlined),
              label: const Text('Finalizar'),
            ),
          if (rental.puedeCancelar)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFFD5D2),
              ),
              onPressed: provider.isMutating ? null : _cancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancelar'),
            ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, RentaProvider provider) {
    final rental = provider.selected!;
    final date = DateFormat('dd/MM/yyyy · hh:mm a');
    final money = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '${rental.monedaSimbolo} ',
    );
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la renta',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _item(
              Icons.login_rounded,
              'Inicio',
              date.format(rental.fechaInicio),
            ),
            _item(
              Icons.logout_rounded,
              'Fin previsto',
              date.format(rental.fechaFin),
            ),
            if (rental.fechaEntregaReal != null)
              _item(
                Icons.assignment_turned_in_outlined,
                'Entrega real',
                date.format(rental.fechaEntregaReal!),
              ),
            _item(
              Icons.timelapse_rounded,
              'Duración',
              '${rental.cantidadDias} días',
            ),
            _item(
              Icons.price_check_outlined,
              'Precio diario',
              money.format(rental.precioPorDia),
            ),
            _item(
              Icons.receipt_long_outlined,
              'Subtotal',
              money.format(rental.subtotal),
            ),
            _item(
              Icons.percent_rounded,
              'Impuestos',
              money.format(rental.impuestos),
            ),
            _item(
              Icons.discount_outlined,
              'Descuentos',
              money.format(rental.descuentos),
            ),
            _item(
              Icons.account_balance_wallet_outlined,
              'Depósito',
              money.format(rental.deposito),
            ),
            _item(
              Icons.currency_exchange_rounded,
              'Tasa aplicada',
              rental.tasaCambioAplicada.toStringAsFixed(6),
            ),
            if (rental.idReservacion != null)
              _item(
                Icons.event_available_outlined,
                'Reservación de origen',
                '#${rental.idReservacion}',
              ),
            if (rental.observaciones?.isNotEmpty == true)
              _item(
                Icons.notes_outlined,
                'Observaciones',
                rental.observaciones!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF56617A)),
        const SizedBox(width: 10),
        SizedBox(
          width: 145,
          child: Text(label, style: const TextStyle(color: Color(0xFF6F788C))),
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

  Widget _error(RentaProvider provider) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 52),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'No fue posible cargar la renta.'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );

  Future<void> _edit() async {
    final rental = context.read<RentaProvider>().selected!;
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => RentaFormPage(renta: rental)),
    );
    if (mounted) await _load();
  }

  Future<void> _openDelivery() => Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => RentaEntregaPage(rentaId: widget.rentaId),
    ),
  );

  Future<void> _openReception() => Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => RentaRecepcionPage(rentaId: widget.rentaId),
    ),
  );

  Future<void> _registerPayment() async {
    final rental = context.read<RentaProvider>().selected!;
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PagoFormPage(initialRentaId: rental.idRenta),
      ),
    );
    if (created == true && mounted) await _load();
  }

  Future<void> _complete() async {
    final provider = context.read<RentaProvider>();
    final rental = provider.selected!;
    final notes = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.assignment_turned_in_outlined),
        title: const Text('Finalizar renta'),
        content: TextField(
          controller: notes,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observaciones de entrega',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) {
      notes.dispose();
      return;
    }
    final success = await provider.complete(
      rental.idRenta,
      FinalizarRentaDto(
        fechaEntregaReal: DateTime.now(),
        rowVersion: rental.rowVersion,
        observaciones: notes.text,
      ),
    );
    notes.dispose();
    if (!mounted) return;
    if (!success) {
      _message(provider.errorMessage ?? 'No fue posible finalizar la renta.');
      return;
    }
    await _load();
    if (mounted) await _openReception();
  }

  Future<void> _cancel() async {
    final provider = context.read<RentaProvider>();
    final rental = provider.selected!;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Cancelar renta'),
        content: const Text(
          'Esta acción liberará el vehículo. Los pagos activos deben anularse previamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancelar renta'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    final success = await provider.cancel(rental.idRenta);
    if (!mounted) return;
    if (!success) {
      _message(provider.errorMessage ?? 'No fue posible cancelar la renta.');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}

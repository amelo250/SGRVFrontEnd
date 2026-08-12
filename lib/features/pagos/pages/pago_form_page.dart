import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_dto.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_form_provider.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_provider.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_summary_card.dart';

class PagoFormPage extends StatefulWidget {
  const PagoFormPage({this.initialRentaId, super.key});

  final int? initialRentaId;

  @override
  State<PagoFormPage> createState() => _PagoFormPageState();
}

class _PagoFormPageState extends State<PagoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _rate = TextEditingController(text: '1');
  final _reference = TextEditingController();
  final _notes = TextEditingController();
  int? _rentalId;
  int? _methodId;
  int? _currencyId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _rentalId = widget.initialRentaId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<PagoFormProvider>();
    await provider.load(preferredRentalId: _rentalId);
    if (!mounted) return;
    final currencies = provider.currencies;
    final methods = provider.methods;
    setState(() {
      _currencyId ??=
          currencies
              .where((item) => item.code.toUpperCase() == 'DOP')
              .firstOrNull
              ?.id ??
          (currencies.isEmpty ? null : currencies.first.id);
      _methodId ??= methods.isEmpty ? null : methods.first.id;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _reference.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<PagoFormProvider>();
    final payments = context.watch<PagoProvider>();
    final currency = form.currencies
        .where((item) => item.id == _currencyId)
        .firstOrNull;
    final isLocal = currency?.code.toUpperCase() == 'DOP';
    final amount = double.tryParse(_amount.text.replaceAll(',', '.')) ?? 0;
    final rate = isLocal
        ? 1.0
        : (double.tryParse(_rate.text.replaceAll(',', '.')) ?? 0);
    final localAmount = form.localAmount(
      amount: amount,
      currencyCode: currency?.code ?? 'DOP',
      rate: rate,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Registrar pago'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: form.loading
          ? const Center(child: CircularProgressIndicator())
          : form.errorMessage != null && form.rentas.isEmpty
          ? _error(form)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Form(
                    key: _formKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fields = _form(
                          form,
                          isLocal: isLocal,
                          localAmount: localAmount,
                        );
                        final summary = form.summary == null
                            ? const SizedBox.shrink()
                            : PagoSummaryCard(summary: form.summary!);
                        return constraints.maxWidth >= 800
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 6, child: fields),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 4, child: summary),
                                ],
                              )
                            : Column(
                                children: [
                                  fields,
                                  const SizedBox(height: 20),
                                  summary,
                                ],
                              );
                      },
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: form.loading
          ? null
          : SafeArea(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: payments.isMutating
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: payments.isMutating
                          ? null
                          : () => _save(form, localAmount),
                      icon: payments.isMutating
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Aplicar pago'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _form(
    PagoFormProvider provider, {
    required bool isLocal,
    required double localAmount,
  }) => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del cobro',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            initialValue: _rentalId,
            decoration: const InputDecoration(
              labelText: 'Renta',
              prefixIcon: Icon(Icons.key_rounded),
              border: OutlineInputBorder(),
            ),
            items: provider.rentas
                .map(
                  (item) => DropdownMenuItem(
                    value: item.idRenta,
                    child: Text(
                      '#${item.idRenta} · ${item.clienteNombre} · ${item.vehiculoDescripcion}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              setState(() => _rentalId = value);
              if (value != null) provider.selectRental(value);
            },
            validator: (value) =>
                value == null ? 'Selecciona una renta.' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _methodId,
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              border: OutlineInputBorder(),
            ),
            items: provider.methods
                .map(
                  (item) =>
                      DropdownMenuItem(value: item.id, child: Text(item.name)),
                )
                .toList(growable: false),
            onChanged: (value) => setState(() => _methodId = value),
            validator: (value) =>
                value == null ? 'Selecciona un método.' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: _currencyId,
            decoration: const InputDecoration(
              labelText: 'Moneda',
              prefixIcon: Icon(Icons.currency_exchange),
              border: OutlineInputBorder(),
            ),
            items: provider.currencies
                .map(
                  (item) => DropdownMenuItem(
                    value: item.id,
                    child: Text('${item.code} · ${item.name}'),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) => setState(() {
              _currencyId = value;
              final selected = provider.currencies
                  .where((item) => item.id == value)
                  .firstOrNull;
              if (selected?.code.toUpperCase() == 'DOP') _rate.text = '1';
            }),
            validator: (value) =>
                value == null ? 'Selecciona una moneda.' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) =>
                      (double.tryParse((value ?? '').replaceAll(',', '.')) ??
                              0) <=
                          0
                      ? 'Indica un monto válido.'
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _rate,
                  enabled: !isLocal,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Tasa de cambio',
                    prefixIcon: Icon(Icons.sync_alt),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) =>
                      !isLocal &&
                          (double.tryParse(
                                    (value ?? '').replaceAll(',', '.'),
                                  ) ??
                                  0) <=
                              0
                      ? 'Indica una tasa válida.'
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Equivalente local: RD\$ ${localAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF3867F4),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('Fecha del pago'),
            subtitle: Text(DateFormat('dd/MM/yyyy · hh:mm a').format(_date)),
            trailing: const Icon(Icons.edit_calendar_outlined),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _reference,
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Referencia',
              prefixIcon: Icon(Icons.tag),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notes,
            maxLength: 500,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observaciones',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes),
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _error(PagoFormProvider provider) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 54),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'No fue posible cargar el formulario.'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (selected != null && mounted) {
      setState(
        () => _date = DateTime(
          selected.year,
          selected.month,
          selected.day,
          DateTime.now().hour,
          DateTime.now().minute,
        ),
      );
    }
  }

  Future<void> _save(PagoFormProvider form, double localAmount) async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amount.text.replaceAll(',', '.'));
    final error = form.validate(amount: amount, localAmount: localAmount);
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    final currency = form.currencies.firstWhere(
      (item) => item.id == _currencyId,
    );
    final ok = await context.read<PagoProvider>().create(
      PagoCreateDto(
        idRenta: _rentalId!,
        idMetodoPago: _methodId!,
        idMoneda: _currencyId!,
        monto: amount,
        tasaCambioAplicada: currency.code.toUpperCase() == 'DOP'
            ? 1
            : double.parse(_rate.text.replaceAll(',', '.')),
        fechaPago: _date,
        referencia: _reference.text,
        observaciones: _notes.text,
      ),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<PagoProvider>().errorMessage ??
                'No fue posible registrar el pago.',
          ),
        ),
      );
    }
  }
}

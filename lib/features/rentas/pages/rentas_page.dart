import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_detail_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_form_page.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_card.dart';

class RentasPage extends StatefulWidget {
  const RentasPage({super.key});

  @override
  State<RentasPage> createState() => _RentasPageState();
}

class _RentasPageState extends State<RentasPage> {
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentaProvider>().load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentaProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rentas', style: TextStyle(fontWeight: FontWeight.w800)),
            Text(
              'Operaciones activas e historial',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            children: [
              _toolbar(context, provider),
              Expanded(child: _body(provider)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, RentaProvider provider) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final search = TextField(
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Buscar cliente, vehículo o estado',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        );
        final actions = Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: provider.isMutating ? null : _convertReservation,
              icon: const Icon(Icons.event_repeat_outlined),
              label: const Text('Convertir reservación'),
            ),
            FilledButton.icon(
              onPressed: provider.isMutating ? null : _create,
              icon: const Icon(Icons.add),
              label: const Text('Nueva renta'),
            ),
          ],
        );
        return constraints.maxWidth >= 760
            ? Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 14),
                  actions,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [search, const SizedBox(height: 12), actions],
              );
      },
    ),
  );

  Widget _body(RentaProvider provider) => switch (provider.status) {
    RentaStatus.initial ||
    RentaStatus.loading => const Center(child: CircularProgressIndicator()),
    RentaStatus.error => _state(
      icon: Icons.cloud_off_outlined,
      title: 'No fue posible cargar las rentas',
      message: provider.errorMessage,
      action: FilledButton.icon(
        onPressed: provider.load,
        icon: const Icon(Icons.refresh),
        label: const Text('Reintentar'),
      ),
    ),
    RentaStatus.empty => RefreshIndicator(
      onRefresh: () => provider.load(refresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            child: _state(
              icon: Icons.key_off_outlined,
              title: 'No hay rentas para mostrar',
              message:
                  'Crea una renta directa o convierte una reservación confirmada.',
            ),
          ),
        ],
      ),
    ),
    RentaStatus.success => Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${provider.totalCount} rentas encontradas',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.load(refresh: true),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1050
                    ? 3
                    : constraints.maxWidth >= 680
                    ? 2
                    : 1;
                return GridView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 260,
                  ),
                  itemCount: provider.items.length,
                  itemBuilder: (_, index) {
                    final item = provider.items[index];
                    return RentaCard(
                      renta: item,
                      onOpen: () => _open(item.idRenta),
                    );
                  },
                );
              },
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: provider.hasPreviousPage
                      ? provider.previousPage
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('Página ${provider.pageNumber} de ${provider.totalPages}'),
                IconButton(
                  onPressed: provider.hasNextPage ? provider.nextPage : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  };

  Widget _state({
    required IconData icon,
    required String title,
    String? message,
    Widget? action,
  }) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 58, color: const Color(0xFF69748C)),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
          ],
          if (action != null) ...[const SizedBox(height: 18), action],
        ],
      ),
    ),
  );

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) context.read<RentaProvider>().search(value);
    });
  }

  Future<void> _create() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RentaFormPage()),
    );
    if (mounted) await context.read<RentaProvider>().load(refresh: true);
  }

  Future<void> _open(int id) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => RentaDetailPage(rentaId: id)),
    );
    if (mounted) await context.read<RentaProvider>().load(refresh: true);
  }

  Future<void> _convertReservation() async {
    final result = await showDialog<_ConversionData>(
      context: context,
      builder: (_) => const _ConvertReservationDialog(),
    );
    if (result == null || !mounted) return;
    final provider = context.read<RentaProvider>();
    final success = await provider.createFromReservation(
      result.reservationId,
      result.dto,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservación convertida correctamente.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'No fue posible convertir la reservación.',
          ),
        ),
      );
    }
  }
}

class _ConvertReservationDialog extends StatefulWidget {
  const _ConvertReservationDialog();

  @override
  State<_ConvertReservationDialog> createState() =>
      _ConvertReservationDialogState();
}

class _ConvertReservationDialogState extends State<_ConvertReservationDialog> {
  final _key = GlobalKey<FormState>();
  final _reservation = TextEditingController();
  final _taxes = TextEditingController(text: '0');
  final _discounts = TextEditingController(text: '0');
  final _deposit = TextEditingController(text: '0');
  final _rate = TextEditingController(text: '1');
  final _notes = TextEditingController();

  @override
  void dispose() {
    _reservation.dispose();
    _taxes.dispose();
    _discounts.dispose();
    _deposit.dispose();
    _rate.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.event_repeat_outlined),
    title: const Text('Convertir reservación'),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _key,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field(
                _reservation,
                'ID de reservación',
                integer: true,
                positive: true,
              ),
              const SizedBox(height: 12),
              _field(_taxes, 'Impuestos'),
              const SizedBox(height: 12),
              _field(_discounts, 'Descuentos'),
              const SizedBox(height: 12),
              _field(_deposit, 'Depósito'),
              const SizedBox(height: 12),
              _field(_rate, 'Tasa de cambio', positive: true),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _submit, child: const Text('Convertir')),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool integer = false,
    bool positive = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (value) {
      if (integer && int.tryParse(value?.trim() ?? '') == null) {
        return 'Introduce un número entero válido';
      }
      final number = double.tryParse(value?.trim() ?? '');
      if (number == null) return 'Introduce un número válido';
      if (positive ? number <= 0 : number < 0)
        return positive ? 'Debe ser mayor que cero' : 'No puede ser negativo';
      return null;
    },
  );

  void _submit() {
    if (!_key.currentState!.validate()) return;
    Navigator.pop(
      context,
      _ConversionData(
        reservationId: int.parse(_reservation.text.trim()),
        dto: ConvertirReservacionRentaDto(
          impuestos: double.parse(_taxes.text.trim()),
          descuentos: double.parse(_discounts.text.trim()),
          deposito: double.parse(_deposit.text.trim()),
          tasaCambioAplicada: double.parse(_rate.text.trim()),
          observaciones: _notes.text,
        ),
      ),
    );
  }
}

class _ConversionData {
  const _ConversionData({required this.reservationId, required this.dto});
  final int reservationId;
  final ConvertirReservacionRentaDto dto;
}

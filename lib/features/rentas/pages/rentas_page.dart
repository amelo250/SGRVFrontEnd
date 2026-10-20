import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_service.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_filters.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_detail_page.dart';
import 'package:sgrv_frontend/features/rentas/pages/renta_form_page.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_card.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_history_card.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_date_filter_bar.dart';
import 'package:sgrv_frontend/features/rentas/widgets/reservacion_conversion_selector.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

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
      context.read<RentaProvider>().changeScope(RentaListScope.active);
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
    return DefaultTabController(
      length: 2,
      child: AppModuleScaffold(
        title: 'Rentas',
        subtitle:
            'Gestiona operaciones activas, cierres e historial de alquileres.',
        body: Column(
          children: [
            _toolbar(context, provider),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Card(
                child: TabBar(
                  onTap: (index) => provider.changeScope(
                    index == 0 ? RentaListScope.active : RentaListScope.history,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.key_rounded), text: 'Rentas activas'),
                    Tab(
                      icon: Icon(Icons.history_rounded),
                      text: 'Rentas pasadas',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: _body(provider)),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, RentaProvider provider) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.end,
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
        ),
        const SizedBox(height: 12),
        AppFilterPanel(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    onChanged: _search,
                    decoration: const InputDecoration(
                      hintText: 'Buscar cliente, vehículo o estado',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  RentaDateFilterBar(
                    from: provider.filters.fechaDesde,
                    to: provider.filters.fechaHasta,
                    onChanged: provider.applyDateRange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
              title: provider.scope == RentaListScope.active
                  ? 'No hay rentas activas'
                  : 'No hay rentas pasadas',
              message: provider.scope == RentaListScope.active
                  ? 'Crea una renta directa o convierte una reservación confirmada.'
                  : 'Las rentas finalizadas o canceladas aparecerán aquí.',
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
                final columns = provider.scope == RentaListScope.history
                    ? constraints.maxWidth >= 1180
                          ? 4
                          : constraints.maxWidth >= 860
                          ? 3
                          : constraints.maxWidth >= 560
                          ? 2
                          : 1
                    : constraints.maxWidth >= 1050
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
                    mainAxisExtent: provider.scope == RentaListScope.active
                        ? 260
                        : 176,
                  ),
                  itemCount: provider.items.length,
                  itemBuilder: (_, index) {
                    final item = provider.items[index];
                    return provider.scope == RentaListScope.active
                        ? RentaCard(
                            renta: item,
                            onOpen: () => _open(item.idRenta),
                          )
                        : RentaHistoryCard(
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
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
  int? _reservationId;
  Reservacion? _selectedReservation;
  PoliticaRentaDto? _policy;
  bool _policyLoading = true;
  String? _policyError;
  bool _discountOverride = false;
  bool get _isAdmin =>
      const ["ADMIN", "SUPADMIN"].contains(context.read<AuthProvider>().role);
  bool get _allowDiscount =>
      (_isAdmin && _discountOverride) ||
      (_policy != null &&
          _selectedReservation != null &&
          _policy!.permiteDescuento(
            _selectedReservation!.fechaInicio,
            _selectedReservation!.fechaFin,
          ));

  @override
  void initState() {
    super.initState();
    _loadPolicy();
  }

  Future<void> _loadPolicy() async {
    setState(() {
      _policyLoading = true;
      _policyError = null;
    });
    final service = RentaService();
    try {
      final policy = await service.getPolicy();
      if (!mounted) return;
      setState(() {
        _policy = policy;
        _policyLoading = false;
        if (!_allowDiscount) _discounts.text = '0';
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _policyLoading = false;
          _policyError = 'No se pudo cargar el mínimo de días de renta.';
        });
      }
    } finally {
      service.dispose();
    }
  }

  final _taxes = TextEditingController(text: '0');
  final _discounts = TextEditingController(text: '0');
  final _deposit = TextEditingController(text: '0');
  final _rate = TextEditingController(text: '1');
  final _notes = TextEditingController();
  final _deliveryPlace = TextEditingController();
  final _receptionPlace = TextEditingController();

  @override
  void dispose() {
    _taxes.dispose();
    _discounts.dispose();
    _deposit.dispose();
    _rate.dispose();
    _notes.dispose();
    _deliveryPlace.dispose();
    _receptionPlace.dispose();
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
              if (_policyLoading) const LinearProgressIndicator(),
              if (_policyError != null) ...[
                Text(_policyError!),
                TextButton(
                  onPressed: _loadPolicy,
                  child: const Text('Reintentar'),
                ),
              ],
              if (_policy != null)
                Text(
                  'Mínimo de renta: ${_policy!.minimoDias} días. Descuento al mínimo requiere habilitación de un administrador.',
                ),
              ReservacionConversionSelector(
                onChanged: (value) => _reservationId = value,
                onReservationChanged: (value) => setState(() {
                  _selectedReservation = value;
                  _deliveryPlace.text = value?.lugarEntrega ?? '';
                  _receptionPlace.text = value?.lugarRecepcion ?? '';
                  if (!_allowDiscount) _discounts.text = '0';
                }),
              ),
              const SizedBox(height: 12),
              _field(_taxes, 'Impuestos'),
              const SizedBox(height: 12),
              if (_isAdmin)
                SwitchListTile(
                  title: const Text('Habilitar descuento excepcional'),
                  value: _discountOverride,
                  onChanged: (value) => setState(() {
                    _discountOverride = value;
                    if (!_allowDiscount) _discounts.text = '0';
                  }),
                ),
              _field(_discounts, 'Descuentos', enabled: _allowDiscount),
              const SizedBox(height: 12),
              _field(_deposit, 'Depósito'),
              const SizedBox(height: 12),
              _field(_rate, 'Tasa DOP por 1 unidad de moneda', positive: true),
              const SizedBox(height: 6),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Para rentas en DOP el backend aplicará tasa 1.',
                  style: TextStyle(color: Color(0xFF6F788C), fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _deliveryPlace,
                maxLength: 250,
                decoration: const InputDecoration(
                  labelText: 'Lugar de entrega',
                ),
                validator: (v) =>
                    (v?.length ?? 0) > 250 ? 'Máximo 250 caracteres' : null,
              ),
              TextFormField(
                controller: _receptionPlace,
                maxLength: 250,
                decoration: const InputDecoration(
                  labelText: 'Lugar de recepción / devolución',
                ),
                validator: (v) =>
                    (v?.length ?? 0) > 250 ? 'Máximo 250 caracteres' : null,
              ),
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
      FilledButton(
        onPressed: _policy == null || _policyLoading || _policyError != null
            ? null
            : _submit,
        child: const Text('Convertir'),
      ),
    ],
  );

  Widget _field(
    TextEditingController controller,
    String label, {
    bool integer = false,
    bool positive = false,
    bool enabled = true,
  }) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: TextInputType.numberWithOptions(decimal: !integer),
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    validator: (value) {
      if (integer && int.tryParse(value?.trim() ?? '') == null) {
        return 'Introduce un número entero válido';
      }
      final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
      if (number == null) return 'Introduce un número válido';
      if (positive ? number <= 0 : number < 0) {
        return positive ? 'Debe ser mayor que cero' : 'No puede ser negativo';
      }
      return null;
    },
  );

  void _submit() {
    if (_policy == null ||
        _selectedReservation == null ||
        _policyLoading ||
        _policyError != null) {
      return;
    }
    if (!_key.currentState!.validate()) return;
    final error = _policy!.validar(
      _selectedReservation!.fechaInicio,
      _selectedReservation!.fechaFin,
      double.parse(_discounts.text.trim().replaceAll(',', '.')),
      permitirDescuentoMinimo: _isAdmin && _discountOverride,
    );
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(
      context,
      _ConversionData(
        reservationId: _reservationId!,
        dto: ConvertirReservacionRentaDto(
          impuestos: double.parse(_taxes.text.trim().replaceAll(',', '.')),
          descuentos: double.parse(_discounts.text.trim().replaceAll(',', '.')),
          deposito: double.parse(_deposit.text.trim().replaceAll(',', '.')),
          tasaCambioAplicada: double.parse(
            _rate.text.trim().replaceAll(',', '.'),
          ),
          observaciones: _notes.text,
          lugarEntrega: _deliveryPlace.text,
          lugarRecepcion: _receptionPlace.text,
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

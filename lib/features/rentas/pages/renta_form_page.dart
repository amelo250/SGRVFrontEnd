import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_service.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/core/utils/money_formatter.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';

class RentaFormPage extends StatefulWidget {
  const RentaFormPage({this.renta, super.key});

  final Renta? renta;

  @override
  State<RentaFormPage> createState() => _RentaFormPageState();
}

class _RentaFormPageState extends State<RentaFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _taxController;
  late final TextEditingController _discountController;
  late final TextEditingController _depositController;
  late final TextEditingController _rateController;
  final _deliveryPlace = TextEditingController();
  final _receptionPlace = TextEditingController();
  late final TextEditingController _notesController;
  int? _clientId;
  int? _vehicleId;
  late DateTime _start;
  late DateTime _end;
  PoliticaRentaDto? _policy;
  bool _policyLoading = true;
  String? _policyError;
  bool _datesChanged = false;
  bool get _sinHora =>
      widget.renta?.periodoSinHora ??
      !(_policy?.capturarHorasPeriodoAlquiler ?? true);
  bool _discountOverride = false;
  bool get _isAdmin =>
      const ["ADMIN", "SUPADMIN"].contains(context.read<AuthProvider>().role);
  bool get _allowDiscount =>
      (_isAdmin && _discountOverride) ||
      (_policy?.permiteDescuento(_start, _end) ?? false);

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
        if (!_editing && !_datesChanged) {
          _end = _start.add(Duration(days: policy.minimoDias - 1));
        }
        if (_sinHora) {
          _start = PeriodoAlquilerFechas.desdeDia(
            PeriodoAlquilerFechas.dia(_start),
          );
          _end = PeriodoAlquilerFechas.desdeDia(
            PeriodoAlquilerFechas.dia(_end),
            fin: true,
          );
        }
        if (!_allowDiscount) _discountController.text = '0';
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

  bool get _editing => widget.renta != null;

  Vehiculo? _selectedVehicle(List<Vehiculo> vehicles) {
    for (final vehicle in vehicles) {
      if (vehicle.idVehiculo == _vehicleId) return vehicle;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final rental = widget.renta;
    _clientId = rental?.idCliente;
    _vehicleId = rental?.idVehiculo;
    _start =
        rental?.fechaInicio ?? DateTime.now().add(const Duration(hours: 1));
    _end = rental?.fechaFin ?? _start.add(const Duration(days: 2));
    _taxController = _money(rental?.impuestos);
    _discountController = _money(rental?.descuentos);
    _depositController = _money(rental?.deposito);
    _rateController = _money(rental?.tasaCambioAplicada ?? 1);
    _notesController = TextEditingController(text: rental?.observaciones);
    _deliveryPlace.text = rental?.lugarEntrega ?? '';
    _receptionPlace.text = rental?.lugarRecepcion ?? '';
    _loadPolicy();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClienteProvider>().cargarParaSelector();
      context.read<VehiculoProvider>().cargar(refresh: true);
    });
  }

  static TextEditingController _money(double? value) =>
      TextEditingController(text: value == null ? '0' : '$value');

  @override
  void dispose() {
    _taxController.dispose();
    _discountController.dispose();
    _depositController.dispose();
    _rateController.dispose();
    _notesController.dispose();
    _deliveryPlace.dispose();
    _receptionPlace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rentalProvider = context.watch<RentaProvider>();
    final clients = context
        .watch<ClienteProvider>()
        .clientes
        .where((item) => item.activo)
        .toList(growable: false);
    final vehicles = context
        .watch<VehiculoProvider>()
        .vehiculos
        .where((item) => item.activo)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Editar renta' : 'Nueva renta'),
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _header(context),
                if (_policyLoading) const LinearProgressIndicator(),
                if (_policyError != null) ...[
                  Text(_policyError!),
                  TextButton(
                    onPressed: _loadPolicy,
                    child: const Text('Reintentar'),
                  ),
                ],
                if (_policy != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Mínimo: ${_policy!.minimoDias} días. Periodo: ${_policy!.dias(_start, _end)} días cobrados. Descuento al mínimo requiere habilitación de un administrador.',
                    ),
                  ),
                const SizedBox(height: 22),
                _section(
                  context,
                  title: 'Cliente y vehículo',
                  icon: Icons.assignment_ind_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) => _responsive(
                      constraints.maxWidth,
                      DropdownButtonFormField<int>(
                        initialValue:
                            clients.any((x) => x.idCliente == _clientId)
                            ? _clientId
                            : null,
                        decoration: _decoration(
                          'Cliente',
                          Icons.person_outline,
                        ),
                        items: clients
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.idCliente,
                                child: Text(item.nombreCompleto),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) => setState(() => _clientId = value),
                        validator: (value) =>
                            value == null ? 'Selecciona un cliente' : null,
                      ),
                      DropdownButtonFormField<int>(
                        initialValue:
                            vehicles.any((x) => x.idVehiculo == _vehicleId)
                            ? _vehicleId
                            : null,
                        decoration: _decoration(
                          'Vehículo',
                          Icons.directions_car_outlined,
                        ),
                        items: vehicles
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.idVehiculo,
                                child: Text(
                                  '${item.marca} ${item.modelo} · ${item.placa}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          final vehicle = vehicles
                              .where((item) => item.idVehiculo == value)
                              .firstOrNull;
                          setState(() {
                            _vehicleId = value;
                            if (vehicle != null &&
                                MoneyFormatter.isLocal(vehicle.monedaCodigo)) {
                              _rateController.text = '1';
                            } else if (!_editing) {
                              _rateController.clear();
                            }
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Selecciona un vehículo' : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  context,
                  title: 'Periodo de alquiler',
                  icon: Icons.date_range_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) => _responsive(
                      constraints.maxWidth,
                      _dateField(
                        'Fecha de inicio',
                        _start,
                        () => _selectDate(true),
                      ),
                      _dateField(
                        'Fecha de fin',
                        _end,
                        () => _selectDate(false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _section(
                  context,
                  title: 'Condiciones financieras',
                  icon: Icons.payments_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final vehicle = _selectedVehicle(vehicles);
                      final currencyCode =
                          vehicle?.monedaCodigo ??
                          widget.renta?.monedaCodigo ??
                          '';
                      final isLocal = MoneyFormatter.isLocal(currencyCode);
                      final rate = isLocal
                          ? 1.0
                          : _parseDecimal(_rateController.text);
                      final localDaily = vehicle == null || rate == null
                          ? null
                          : MoneyFormatter.toLocal(vehicle.precioPorDia, rate);
                      return Column(
                        children: [
                          if (vehicle != null) ...[
                            _currencyNotice(vehicle, rate, localDaily),
                            const SizedBox(height: 14),
                          ],
                          if (_isAdmin)
                            SwitchListTile(
                              title: const Text(
                                'Habilitar descuento excepcional',
                              ),
                              value: _discountOverride,
                              onChanged: (value) => setState(() {
                                _discountOverride = value;
                                if (!_allowDiscount) {
                                  _discountController.text = '0';
                                }
                              }),
                            ),
                          _responsive(
                            constraints.maxWidth,
                            _numberField('Impuestos', _taxController),
                            _numberField(
                              'Descuentos',
                              _discountController,
                              enabled: _allowDiscount,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _responsive(
                            constraints.maxWidth,
                            _numberField('Depósito', _depositController),
                            _numberField(
                              isLocal
                                  ? 'Tasa de cambio (DOP)'
                                  : 'Tasa DOP por 1 $currencyCode',
                              _rateController,
                              positive: true,
                              enabled: !isLocal,
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _deliveryPlace,
                            maxLength: 250,
                            decoration: const InputDecoration(
                              labelText: 'Lugar de entrega del vehículo',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => (value?.length ?? 0) > 250
                                ? 'Máximo 250 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _receptionPlace,
                            maxLength: 250,
                            decoration: const InputDecoration(
                              labelText: 'Lugar de recepción / devolución',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => (value?.length ?? 0) > 250
                                ? 'Máximo 250 caracteres'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 4,
                            maxLength: 500,
                            decoration: _decoration(
                              'Observaciones',
                              Icons.notes_outlined,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed:
                        rentalProvider.isMutating ||
                            _policyLoading ||
                            _policy == null ||
                            _policyError != null
                        ? null
                        : _save,
                    icon: rentalProvider.isMutating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Text(_editing ? 'Guardar cambios' : 'Crear renta'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _editing
              ? 'Actualiza las condiciones de la renta'
              : 'Registra una nueva entrega',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'La tarifa, moneda y totales definitivos serán calculados por el servidor.',
          style: TextStyle(color: Color(0xFFDDE5FF)),
        ),
      ],
    ),
  );

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );

  Widget _responsive(double width, Widget first, Widget second) => width >= 680
      ? Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        )
      : Column(children: [first, const SizedBox(height: 14), second]);

  Widget _dateField(String label, DateTime value, VoidCallback onTap) =>
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: InputDecorator(
          decoration: _decoration(label, Icons.schedule_outlined),
          child: Text(PeriodoAlquilerFechas.formato(value, _sinHora)),
        ),
      );

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool positive = false,
    bool enabled = true,
    ValueChanged<String>? onChanged,
  }) => TextFormField(
    controller: controller,
    enabled: enabled,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: _decoration(label, Icons.attach_money_rounded),
    validator: (value) {
      final number = _parseDecimal(value);
      if (number == null) return 'Introduce un número válido';
      if (positive ? number <= 0 : number < 0) {
        return positive ? 'Debe ser mayor que cero' : 'No puede ser negativo';
      }
      return null;
    },
    onChanged: onChanged,
  );

  Widget _currencyNotice(
    Vehiculo vehicle,
    double? rate,
    double? localDaily,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: .32),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .28),
      ),
    ),
    child: Text(
      MoneyFormatter.isLocal(vehicle.monedaCodigo)
          ? 'Tarifa del vehículo: ${MoneyFormatter.format(vehicle.precioPorDia, currencyCode: vehicle.monedaCodigo, currencySymbol: vehicle.monedaSimbolo)}. Al ser DOP, la tasa se fija en 1.'
          : 'Tarifa del vehículo: ${MoneyFormatter.format(vehicle.precioPorDia, currencyCode: vehicle.monedaCodigo, currencySymbol: vehicle.monedaSimbolo)}. '
                '${rate == null || localDaily == null ? 'Indica cuántos DOP equivalen a 1 ${vehicle.monedaCodigo}.' : 'Con tasa ${rate.toStringAsFixed(4)}, equivale a RD\$ ${localDaily.toStringAsFixed(2)} por día.'}',
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
  );

  static double? _parseDecimal(String? value) =>
      double.tryParse((value ?? '').trim().replaceAll(',', '.'));

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
    ),
  );

  Future<void> _selectDate(bool start) async {
    final initial = start ? _start : _end;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    if (_sinHora) {
      setState(() {
        _datesChanged = true;
        if (start) {
          _start = PeriodoAlquilerFechas.desdeDia(date);
        } else {
          _end = PeriodoAlquilerFechas.desdeDia(date, fin: true);
        }
        if (!_allowDiscount) _discountController.text = '0';
      });
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;
    final result = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      _datesChanged = true;
      if (start) {
        _start = result;
      } else {
        _end = result;
      }
      if (!_allowDiscount) _discountController.text = '0';
    });
  }

  Future<void> _save() async {
    if (_policy == null || _policyLoading || _policyError != null) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_end.isAfter(_start)) {
      _message('La fecha final debe ser posterior a la fecha inicial.');
      return;
    }
    final policyError = _policy!.validar(
      _start,
      _end,
      _parseDecimal(_discountController.text) ?? 0,
      permitirDescuentoMinimo: _isAdmin && _discountOverride,
    );
    if (policyError != null) {
      _message(policyError);
      return;
    }
    final provider = context.read<RentaProvider>();
    final common = RentaCreateDto(
      idCliente: _clientId!,
      idVehiculo: _vehicleId!,
      fechaInicio: _start,
      fechaFin: _end,
      impuestos: _parseDecimal(_taxController.text)!,
      descuentos: _parseDecimal(_discountController.text)!,
      deposito: _parseDecimal(_depositController.text)!,
      tasaCambioAplicada:
          MoneyFormatter.isLocal(
            _selectedVehicle(
                  context.read<VehiculoProvider>().vehiculos,
                )?.monedaCodigo ??
                widget.renta?.monedaCodigo ??
                '',
          )
          ? 1
          : _parseDecimal(_rateController.text)!,
      observaciones: _notesController.text,
      lugarEntrega: _deliveryPlace.text,
      lugarRecepcion: _receptionPlace.text,
    );
    final success = _editing
        ? await provider.update(
            widget.renta!.idRenta,
            RentaUpdateDto(
              idCliente: common.idCliente,
              idVehiculo: common.idVehiculo,
              fechaInicio: common.fechaInicio,
              fechaFin: common.fechaFin,
              impuestos: common.impuestos,
              descuentos: common.descuentos,
              deposito: common.deposito,
              tasaCambioAplicada: common.tasaCambioAplicada,
              observaciones: common.observaciones,
              lugarEntrega: common.lugarEntrega,
              lugarRecepcion: common.lugarRecepcion,
              rowVersion: widget.renta!.rowVersion,
            ),
          )
        : await provider.create(common);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context, true);
    } else {
      _message(provider.errorMessage ?? 'No fue posible guardar la renta.');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}

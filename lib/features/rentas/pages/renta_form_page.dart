import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_dto.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';

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
  late final TextEditingController _notesController;
  int? _clientId;
  int? _vehicleId;
  late DateTime _start;
  late DateTime _end;

  bool get _editing => widget.renta != null;

  @override
  void initState() {
    super.initState();
    final rental = widget.renta;
    _clientId = rental?.idCliente;
    _vehicleId = rental?.idVehiculo;
    _start =
        rental?.fechaInicio ?? DateTime.now().add(const Duration(hours: 1));
    _end =
        rental?.fechaFin ??
        DateTime.now().add(const Duration(days: 1, hours: 1));
    _taxController = _money(rental?.impuestos);
    _discountController = _money(rental?.descuentos);
    _depositController = _money(rental?.deposito);
    _rateController = _money(rental?.tasaCambioAplicada ?? 1);
    _notesController = TextEditingController(text: rental?.observaciones);
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(_editing ? 'Editar renta' : 'Nueva renta'),
        backgroundColor: Colors.white,
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
                        onChanged: (value) =>
                            setState(() => _vehicleId = value),
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
                    builder: (context, constraints) => Column(
                      children: [
                        _responsive(
                          constraints.maxWidth,
                          _numberField('Impuestos', _taxController),
                          _numberField('Descuentos', _discountController),
                        ),
                        const SizedBox(height: 14),
                        _responsive(
                          constraints.maxWidth,
                          _numberField('Depósito', _depositController),
                          _numberField(
                            'Tasa de cambio',
                            _rateController,
                            positive: true,
                          ),
                        ),
                        const SizedBox(height: 14),
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
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: rentalProvider.isMutating ? null : _save,
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
      gradient: const LinearGradient(
        colors: [Color(0xFF315BD5), Color(0xFF6B55E8)],
      ),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _editing
              ? 'Actualiza las condiciones de la renta'
              : 'Registra una nueva entrega',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE4E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF3867F4)),
            const SizedBox(width: 10),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: InputDecorator(
          decoration: _decoration(label, Icons.schedule_outlined),
          child: Text(DateFormat('dd/MM/yyyy · hh:mm a').format(value)),
        ),
      );

  Widget _numberField(
    String label,
    TextEditingController controller, {
    bool positive = false,
  }) => TextFormField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: _decoration(label, Icons.attach_money_rounded),
    validator: (value) {
      final number = double.tryParse(value?.trim() ?? '');
      if (number == null) return 'Introduce un número válido';
      if (positive ? number <= 0 : number < 0) {
        return positive ? 'Debe ser mayor que cero' : 'No puede ser negativo';
      }
      return null;
    },
  );

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: const Color(0xFFF8FAFD),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE1E6EF)),
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
      if (start) {
        _start = result;
      } else {
        _end = result;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_end.isAfter(_start)) {
      _message('La fecha final debe ser posterior a la fecha inicial.');
      return;
    }
    final provider = context.read<RentaProvider>();
    final common = RentaCreateDto(
      idCliente: _clientId!,
      idVehiculo: _vehicleId!,
      fechaInicio: _start,
      fechaFin: _end,
      impuestos: double.parse(_taxController.text.trim()),
      descuentos: double.parse(_discountController.text.trim()),
      deposito: double.parse(_depositController.text.trim()),
      tasaCambioAplicada: double.parse(_rateController.text.trim()),
      observaciones: _notesController.text,
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

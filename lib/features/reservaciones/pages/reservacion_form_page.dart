import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_dto.dart';
import 'package:sgrv_frontend/features/reservaciones/providers/reservacion_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';

class ReservacionFormPage extends StatefulWidget {
  const ReservacionFormPage({this.reservacion, super.key});

  final Reservacion? reservacion;

  @override
  State<ReservacionFormPage> createState() => _ReservacionFormPageState();
}

class _ReservacionFormPageState extends State<ReservacionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _observationController = TextEditingController();
  int? _idCliente;
  int? _idVehiculo;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    final current = widget.reservacion;
    _idCliente = current?.idCliente;
    _idVehiculo = current?.idVehiculo;
    _fechaInicio = current?.fechaInicio;
    _fechaFin = current?.fechaFin;
    _observationController.text = current?.observacion ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clients = context.read<ClienteProvider>();
      final vehicles = context.read<VehiculoProvider>();
      if (clients.clientes.isEmpty) clients.cargar();
      if (vehicles.vehiculos.isEmpty) vehicles.cargar();
    });
  }

  @override
  void dispose() {
    _observationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<ReservacionProvider>();
    final clients = context.watch<ClienteProvider>();
    final vehicles = context.watch<VehiculoProvider>();
    final loadingDependencies =
        clients.status == ClienteStatus.loading ||
        vehicles.status == VehiculoStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reservacion == null
              ? 'Nueva reservación'
              : 'Editar reservación',
        ),
      ),
      body: loadingDependencies
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Cliente y vehículo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _availableValue(
                      _idCliente,
                      clients.clientes
                          .where((x) => x.activo)
                          .map((x) => x.idCliente),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Cliente',
                      border: OutlineInputBorder(),
                    ),
                    items: clients.clientes
                        .where((x) => x.activo)
                        .map(
                          (x) => DropdownMenuItem(
                            value: x.idCliente,
                            child: Text(x.nombreCompleto),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _idCliente = value),
                    validator: (value) =>
                        value == null ? 'Selecciona un cliente' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _availableValue(
                      _idVehiculo,
                      vehicles.vehiculos
                          .where((x) => x.activo)
                          .map((x) => x.idVehiculo),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Vehículo',
                      border: OutlineInputBorder(),
                    ),
                    items: vehicles.vehiculos
                        .where((x) => x.activo)
                        .map(
                          (x) => DropdownMenuItem(
                            value: x.idVehiculo,
                            child: Text('${x.marca} ${x.modelo} (${x.placa})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _idVehiculo = value),
                    validator: (value) =>
                        value == null ? 'Selecciona un vehículo' : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Periodo',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 14),
                  _dateTimeField(
                    'Inicio',
                    _fechaInicio,
                    (value) => setState(() => _fechaInicio = value),
                  ),
                  const SizedBox(height: 12),
                  _dateTimeField(
                    'Fin',
                    _fechaFin,
                    (value) => setState(() => _fechaFin = value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _observationController,
                    maxLength: 500,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observación',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: reservationProvider.isMutating ? null : _save,
                    icon: reservationProvider.isMutating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      reservationProvider.isMutating ? 'Guardando…' : 'Guardar',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _dateTimeField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final selected = await _pickDateTime(value);
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.event),
          errorText: value == null ? 'Campo obligatorio' : null,
        ),
        child: Text(
          value == null
              ? 'Seleccionar fecha y hora'
              : DateFormat('dd/MM/yyyy HH:mm').format(value),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime? current) async {
    final base = current ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaInicio == null || _fechaFin == null) {
      _showMessage('Debes indicar las fechas de inicio y fin.');
      return;
    }
    if (!_fechaFin!.isAfter(_fechaInicio!)) {
      _showMessage('La fecha final debe ser posterior a la inicial.');
      return;
    }

    final dto = ReservacionDto(
      idVehiculo: _idVehiculo!,
      idCliente: _idCliente!,
      fechaInicio: _fechaInicio!,
      fechaFin: _fechaFin!,
      observacion: _observationController.text,
    );
    final provider = context.read<ReservacionProvider>();
    final current = widget.reservacion;
    final success = current == null
        ? await provider.create(dto)
        : await provider.update(current.idReservacion, dto);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _showMessage(
        provider.errorMessage ?? 'No fue posible guardar la reservación.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static int? _availableValue(int? current, Iterable<int> values) =>
      current != null && values.contains(current) ? current : null;
}

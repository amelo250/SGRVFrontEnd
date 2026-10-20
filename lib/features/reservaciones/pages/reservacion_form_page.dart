import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:sgrv_frontend/features/configuracion/services/configuracion_alquiler_service.dart';
import 'package:sgrv_frontend/features/rentas/dtos/politica_renta_dto.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion_dto.dart';
import 'package:sgrv_frontend/features/reservaciones/providers/reservacion_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class ReservacionFormPage extends StatefulWidget {
  const ReservacionFormPage({this.reservacion, super.key});

  final Reservacion? reservacion;

  @override
  State<ReservacionFormPage> createState() => _ReservacionFormPageState();
}

class _ReservacionFormPageState extends State<ReservacionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryPlace = TextEditingController();
  final _receptionPlace = TextEditingController();
  final _observationController = TextEditingController();
  int? _idCliente;
  int? _idVehiculo;
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _sinHora = false;
  bool _periodoLoading = true;
  String? _periodoError;
  Future<void> _loadPeriodo() async {
    final service = ConfiguracionAlquilerService();
    try {
      final sinHora =
          widget.reservacion?.periodoSinHora ?? !(await service.get());
      if (mounted) {
        setState(() {
          _sinHora = sinHora;
          _periodoError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _periodoError = 'No se pudo cargar la configuración del periodo.',
        );
      }
    } finally {
      service.dispose();
      if (mounted) {
        setState(() => _periodoLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPeriodo();
    final current = widget.reservacion;
    _idCliente = current?.idCliente;
    _idVehiculo = current?.idVehiculo;
    _fechaInicio = current?.fechaInicio;
    _fechaFin = current?.fechaFin;
    _observationController.text = current?.observacion ?? '';
    _deliveryPlace.text = current?.lugarEntrega ?? '';
    _receptionPlace.text = current?.lugarRecepcion ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clients = context.read<ClienteProvider>();
      final vehicles = context.read<VehiculoProvider>();
      clients.cargarParaSelector();
      vehicles.cargar();
    });
  }

  @override
  void dispose() {
    _observationController.dispose();
    _deliveryPlace.dispose();
    _receptionPlace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = context.watch<ReservacionProvider>();
    final clients = context.watch<ClienteProvider>();
    final vehicles = context.watch<VehiculoProvider>();
    final loadingDependencies =
        _periodoLoading ||
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
          : AppResponsiveContent(
              maxWidth: 940,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    AppPageHeader(
                      title: widget.reservacion == null
                          ? 'Nueva reservación'
                          : 'Editar reservación',
                      subtitle: 'Cliente, vehículo y período solicitado.',
                      icon: Icons.event_available_rounded,
                    ),
                    if (_periodoError != null) ...[
                      Text(_periodoError!),
                      TextButton(
                        onPressed: _loadPeriodo,
                        child: const Text("Reintentar"),
                      ),
                    ],
                    const SizedBox(height: 22),
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
                              child: Text(
                                '${x.marca} ${x.modelo} (${x.placa})',
                              ),
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
                    if (_fechaInicio != null && _fechaFin != null)
                      Text(
                        'Periodo: ${const PoliticaRentaDto(minimoDias: 3).dias(_fechaInicio!, _fechaFin!)} días (incluye inicio y fin).',
                      ),
                    const SizedBox(height: 12),
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
                        reservationProvider.isMutating
                            ? 'Guardando…'
                            : 'Guardar',
                      ),
                    ),
                  ],
                ),
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
        final selected = await _pickDateTime(value, fin: label == 'Fin');
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
              ? (_sinHora ? 'Seleccionar día' : 'Seleccionar fecha y hora')
              : PeriodoAlquilerFechas.formato(value, _sinHora),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDateTime(DateTime? current, {bool fin = false}) async {
    final base = current ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return null;
    if (_sinHora) return PeriodoAlquilerFechas.desdeDia(date, fin: fin);
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (_periodoLoading || _periodoError != null) return;
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
      lugarEntrega: _deliveryPlace.text,
      lugarRecepcion: _receptionPlace.text,
    );
    final provider = context.read<ReservacionProvider>();
    _loadPeriodo();
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

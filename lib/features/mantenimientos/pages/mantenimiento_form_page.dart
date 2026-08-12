import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';
import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento_dto.dart';
import 'package:sgrv_frontend/features/mantenimientos/providers/mantenimiento_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class MantenimientoFormPage extends StatefulWidget {
  const MantenimientoFormPage({
    this.mantenimiento,
    this.idVehiculo,
    this.vehiculoNombre,
    super.key,
  });
  final Mantenimiento? mantenimiento;
  final int? idVehiculo;
  final String? vehiculoNombre;
  @override
  State<MantenimientoFormPage> createState() => _MantenimientoFormPageState();
}

class _MantenimientoFormPageState extends State<MantenimientoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _taller = TextEditingController();
  final _km = TextEditingController();
  final _costo = TextEditingController();
  final _observacion = TextEditingController();
  int? _vehiculo;
  int? _tipo;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    final item = widget.mantenimiento;
    _vehiculo = widget.idVehiculo ?? item?.idVehiculo;
    _tipo = item?.idTipoMantenimiento;
    _fecha = item?.fecha ?? DateTime.now();
    _taller.text = item?.taller ?? '';
    _km.text = item?.kilometraje?.toString() ?? '';
    _costo.text = item?.costo?.toString() ?? '';
    _observacion.text = item?.observacion ?? '';
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<MantenimientoProvider>().loadCatalogs(),
    );
  }

  @override
  Widget build(BuildContext context) => AppModuleScaffold(
    title: widget.mantenimiento == null
        ? 'Registrar mantenimiento'
        : 'Editar mantenimiento',
    body: Consumer<MantenimientoProvider>(
      builder: (context, provider, _) => Form(
        key: _formKey,
        child: ListView(
          children: [
            AppSectionCard(
              title: 'Información del servicio',
              icon: Icons.build_circle_outlined,
              child: Column(
                children: [
                  if (widget.idVehiculo != null)
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car_outlined),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.vehiculoNombre ??
                                  'Vehículo #${widget.idVehiculo}',
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      initialValue: _vehiculo,
                      decoration: const InputDecoration(labelText: 'Vehículo'),
                      items: provider.vehiculos
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setState(() => _vehiculo = value),
                      validator: (value) =>
                          value == null ? 'Selecciona un vehículo.' : null,
                    ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _tipo,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de mantenimiento',
                    ),
                    items: provider.tipos
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _tipo = value),
                    validator: (value) =>
                        value == null ? 'Selecciona un tipo.' : null,
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    leading: const Icon(Icons.calendar_month_rounded),
                    title: const Text('Fecha del mantenimiento'),
                    subtitle: Text(
                      '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _taller,
                    decoration: const InputDecoration(labelText: 'Taller'),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _km,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kilometraje',
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _costo,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Costo'),
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            return amount == null || amount < 0
                                ? 'Indica un costo válido.'
                                : null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _observacion,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: provider.saving ? null : _save,
              icon: provider.saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('Guardar mantenimiento'),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _pickDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (value != null) setState(() => _fecha = value);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<MantenimientoProvider>();
    final ok = await provider.save(
      MantenimientoDto(
        idVehiculo: _vehiculo!,
        idTipoMantenimiento: _tipo!,
        fecha: _fecha,
        taller: _taller.text.trim().isEmpty ? null : _taller.text.trim(),
        kilometraje: int.tryParse(_km.text),
        costo: double.parse(_costo.text),
        observacion: _observacion.text.trim().isEmpty
            ? null
            : _observacion.text.trim(),
      ),
      id: widget.mantenimiento?.idMantenimiento,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No fue posible guardar.')),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../models/gasto.dart';
import '../models/gasto_dto.dart';
import '../providers/gasto_provider.dart';

class GastoFormPage extends StatefulWidget {
  const GastoFormPage({this.gasto, super.key});
  final Gasto? gasto;
  @override
  State<GastoFormPage> createState() => _GastoFormPageState();
}

class _GastoFormPageState extends State<GastoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _concepto;
  late final TextEditingController _monto;
  late final TextEditingController _tasa;
  late final TextEditingController _proveedor;
  late final TextEditingController _comprobante;
  late final TextEditingController _kilometraje;
  late final TextEditingController _taller;
  late final TextEditingController _observaciones;
  int? _tipo;
  int? _moneda;
  int? _vehiculo;
  late DateTime _fecha;

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    _tipo = g?.idTipoGasto;
    _moneda = g?.idMoneda;
    _vehiculo = g?.idVehiculo;
    _fecha = g?.fecha ?? DateTime.now();
    _concepto = TextEditingController(text: g?.concepto ?? '');
    _monto = TextEditingController(text: g?.monto.toString() ?? '');
    _tasa = TextEditingController(
      text: g?.tasaCambioAplicada.toString() ?? '1',
    );
    _proveedor = TextEditingController(text: g?.proveedor ?? '');
    _comprobante = TextEditingController(text: g?.numeroComprobante ?? '');
    _kilometraje = TextEditingController(
      text: g?.kilometraje?.toString() ?? '',
    );
    _taller = TextEditingController(text: g?.taller ?? '');
    _observaciones = TextEditingController(text: g?.observaciones ?? '');
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<GastoProvider>().loadCatalogs(),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _concepto,
      _monto,
      _tasa,
      _proveedor,
      _comprobante,
      _kilometraje,
      _taller,
      _observaciones,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() ||
        _tipo == null ||
        _moneda == null) {
      return;
    }
    final dto = GastoDto(
      idTipoGasto: _tipo!,
      idMoneda: _moneda!,
      idVehiculo: _vehiculo,
      fecha: _fecha,
      concepto: _concepto.text,
      numeroComprobante: _comprobante.text,
      proveedor: _proveedor.text,
      monto: double.parse(_monto.text),
      tasaCambioAplicada: double.parse(_tasa.text),
      kilometraje: int.tryParse(_kilometraje.text),
      taller: _taller.text,
      observaciones: _observaciones.text,
      rowVersion: widget.gasto?.rowVersion,
    );
    final provider = context.read<GastoProvider>();
    final ok = await provider.save(dto, id: widget.gasto?.idGasto);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'No fue posible guardar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<GastoProvider>(
    builder: (context, provider, _) {
      return AppModuleScaffold(
        title: widget.gasto == null ? 'Nuevo gasto' : 'Editar gasto',
        subtitle:
            'Registra mantenimiento y gastos operativos con su moneda aplicada.',
        body: provider.saving && provider.tipos.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      AppSectionCard(
                        title: 'Clasificación',
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _field(
                              DropdownButtonFormField<int>(
                                initialValue: _tipo,
                                decoration: const InputDecoration(
                                  labelText: 'Tipo de gasto',
                                  prefixIcon: Icon(Icons.category_rounded),
                                ),
                                items: provider.tipos
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text(e.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _tipo = v),
                                validator: (v) =>
                                    v == null ? 'Selecciona un tipo' : null,
                              ),
                            ),
                            _field(
                              DropdownButtonFormField<int>(
                                initialValue: _moneda,
                                decoration: const InputDecoration(
                                  labelText: 'Moneda',
                                  prefixIcon: Icon(
                                    Icons.currency_exchange_rounded,
                                  ),
                                ),
                                items: provider.monedas
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e.id,
                                        child: Text('${e.code} · ${e.name}'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _moneda = v),
                                validator: (v) =>
                                    v == null ? 'Selecciona una moneda' : null,
                              ),
                            ),
                            _field(
                              DropdownButtonFormField<int>(
                                initialValue: _vehiculo,
                                decoration: const InputDecoration(
                                  labelText: 'Vehículo (opcional)',
                                  prefixIcon: Icon(
                                    Icons.directions_car_rounded,
                                  ),
                                ),
                                items: [
                                  const DropdownMenuItem<int>(
                                    value: null,
                                    child: Text('Gasto operativo general'),
                                  ),
                                  ...provider.vehiculos.map(
                                    (e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.name),
                                    ),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _vehiculo = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppSectionCard(
                        title: 'Información financiera',
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _field(
                              TextFormField(
                                controller: _concepto,
                                decoration: const InputDecoration(
                                  labelText: 'Concepto',
                                  prefixIcon: Icon(Icons.description_rounded),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Escribe el concepto'
                                    : null,
                              ),
                            ),
                            _field(
                              TextFormField(
                                controller: _monto,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Monto',
                                  prefixIcon: Icon(Icons.payments_rounded),
                                ),
                                validator: (v) =>
                                    (double.tryParse(v ?? '') ?? 0) <= 0
                                    ? 'Monto inválido'
                                    : null,
                              ),
                            ),
                            _field(
                              TextFormField(
                                controller: _tasa,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Tasa aplicada',
                                  prefixIcon: Icon(Icons.calculate_rounded),
                                ),
                                validator: (v) =>
                                    (double.tryParse(v ?? '') ?? 0) <= 0
                                    ? 'Tasa inválida'
                                    : null,
                              ),
                            ),
                            _field(
                              TextFormField(
                                controller: _proveedor,
                                decoration: const InputDecoration(
                                  labelText: 'Proveedor',
                                  prefixIcon: Icon(Icons.store_rounded),
                                ),
                              ),
                            ),
                            _field(
                              TextFormField(
                                controller: _comprobante,
                                decoration: const InputDecoration(
                                  labelText: 'Comprobante',
                                  prefixIcon: Icon(Icons.receipt_rounded),
                                ),
                              ),
                            ),
                            _field(
                              InkWell(
                                onTap: () async {
                                  final value = await showDatePicker(
                                    context: context,
                                    initialDate: _fecha,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                  );
                                  if (value != null) {
                                    setState(() => _fecha = value);
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Fecha',
                                    prefixIcon: Icon(
                                      Icons.calendar_today_rounded,
                                    ),
                                  ),
                                  child: Text(
                                    '${_fecha.day}/${_fecha.month}/${_fecha.year}',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppSectionCard(
                        title: 'Mantenimiento (opcional)',
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _field(
                              TextFormField(
                                controller: _kilometraje,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Kilometraje',
                                  prefixIcon: Icon(Icons.speed_rounded),
                                ),
                              ),
                            ),
                            _field(
                              TextFormField(
                                controller: _taller,
                                decoration: const InputDecoration(
                                  labelText: 'Taller',
                                  prefixIcon: Icon(Icons.car_repair_rounded),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 760,
                              child: TextFormField(
                                controller: _observaciones,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Observaciones',
                                  prefixIcon: Icon(Icons.notes_rounded),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: provider.saving ? null : _save,
                          icon: provider.saving
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_rounded),
                          label: const Text('Guardar gasto'),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
      );
    },
  );

  Widget _field(Widget child) => SizedBox(width: 360, child: child);
}

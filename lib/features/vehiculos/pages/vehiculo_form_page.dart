import 'package:flutter/material.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_dto.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehicle_catalog_option.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehicle_catalog_provider.dart';

class VehiculoFormPage extends StatefulWidget {
  const VehiculoFormPage({this.vehiculo, super.key});
  final Vehiculo? vehiculo;

  @override
  State<VehiculoFormPage> createState() => _VehiculoFormPageState();
}

class _VehiculoFormPageState extends State<VehiculoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late TipoPropiedadVehiculo _tipoPropiedad;
  int? _idCombustible;
  int? _idTransmision;
  int? _idTipo;
  int? _idMoneda;

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehiculo;
    _tipoPropiedad = vehicle?.tipoPropiedad ?? TipoPropiedadVehiculo.propio;
    _idCombustible = vehicle?.idCombustible;
    _idTransmision = vehicle?.idTransmision;
    _idTipo = vehicle?.idTipo;
    _idMoneda = vehicle?.idMonedaTarifa;
    _fields = {
      'marca': TextEditingController(text: vehicle?.marca),
      'modelo': TextEditingController(text: vehicle?.modelo),
      'placa': TextEditingController(text: vehicle?.placa),
      'anio': TextEditingController(text: vehicle?.anio.toString()),
      'proveedor': TextEditingController(
        text: vehicle?.idProveedorVehiculo?.toString(),
      ),
      'precio': TextEditingController(text: vehicle?.precioPorDia.toString()),
      'deposito': TextEditingController(
        text: vehicle?.depositoCombustible.toString(),
      ),
      'kilometraje': TextEditingController(
        text: vehicle?.kilometraje.toString(),
      ),
      'vin': TextEditingController(text: vehicle?.vin),
      'color': TextEditingController(text: vehicle?.color),
      'descripcion': TextEditingController(text: vehicle?.descripcion),
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<VehicleCatalogProvider>().load(force: true);
    });
  }

  @override
  void dispose() {
    for (final field in _fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();
    final catalogs = context.watch<VehicleCatalogProvider>();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.vehiculo == null ? 'Nuevo vehículo' : 'Editar vehículo',
        ),
      ),
      body: catalogs.loading
          ? const Center(child: CircularProgressIndicator())
          : catalogs.errorMessage != null
          ? _catalogError(catalogs)
          : Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    children: [
                      _formHeader(),
                      const SizedBox(height: 20),
                      _sectionCard(
                        icon: Icons.directions_car_rounded,
                        title: 'Información general',
                        subtitle:
                            'Datos principales para identificar el vehículo.',
                        child: Column(
                          children: [
                            _responsiveRow(
                              _field(
                                'marca',
                                'Marca',
                                icon: Icons.badge_outlined,
                              ),
                              _field(
                                'modelo',
                                'Modelo',
                                icon: Icons.directions_car_outlined,
                              ),
                            ),
                            _responsiveRow(
                              _field(
                                'placa',
                                'Placa',
                                icon: Icons.pin_outlined,
                              ),
                              _field(
                                'anio',
                                'Año',
                                numeric: true,
                                icon: Icons.calendar_today_outlined,
                              ),
                            ),
                            _responsiveRow(
                              _field(
                                'vin',
                                'VIN',
                                required: false,
                                icon: Icons.qr_code_rounded,
                              ),
                              _field(
                                'color',
                                'Color',
                                required: false,
                                icon: Icons.palette_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionCard(
                        icon: Icons.tune_rounded,
                        title: 'Clasificación',
                        subtitle:
                            'Características operativas y propiedad del vehículo.',
                        child: Column(
                          children: [
                            _propertyDropdown(),
                            const SizedBox(height: 12),
                            _responsiveRow(
                              _catalogDropdown(
                                label: 'Combustible',
                                icon: Icons.local_gas_station_outlined,
                                value: _validValue(
                                  _idCombustible,
                                  catalogs.fuels,
                                ),
                                options: catalogs.fuels,
                                onChanged: (value) =>
                                    setState(() => _idCombustible = value),
                              ),
                              _catalogDropdown(
                                label: 'Transmisión',
                                icon: Icons.settings_suggest_outlined,
                                value: _validValue(
                                  _idTransmision,
                                  catalogs.transmissions,
                                ),
                                options: catalogs.transmissions,
                                onChanged: (value) =>
                                    setState(() => _idTransmision = value),
                              ),
                            ),
                            _responsiveRow(
                              _catalogDropdown(
                                label: 'Tipo de vehículo',
                                icon: Icons.category_outlined,
                                value: _validValue(_idTipo, catalogs.types),
                                options: catalogs.types,
                                onChanged: (value) =>
                                    setState(() => _idTipo = value),
                              ),
                              _currencyDropdown(catalogs),
                            ),
                            if (_tipoPropiedad == TipoPropiedadVehiculo.tercero)
                              _field(
                                'proveedor',
                                'ID proveedor',
                                numeric: true,
                                icon: Icons.handshake_outlined,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _sectionCard(
                        icon: Icons.payments_outlined,
                        title: 'Tarifa y operación',
                        subtitle:
                            'Valores utilizados durante la renta del vehículo.',
                        child: Column(
                          children: [
                            _responsiveRow(
                              _field(
                                'precio',
                                'Precio por día',
                                numeric: true,
                                icon: Icons.attach_money_rounded,
                              ),
                              _field(
                                'deposito',
                                'Depósito de combustible',
                                numeric: true,
                                suffixText: 'gal',
                                icon: Icons.water_drop_outlined,
                              ),
                            ),
                            _field(
                              'kilometraje',
                              'Kilometraje',
                              numeric: true,
                              icon: Icons.speed_rounded,
                            ),
                            _field(
                              'descripcion',
                              'Descripción',
                              required: false,
                              maxLines: 3,
                              icon: Icons.notes_rounded,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _actionBar(provider),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _responsiveRow(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 600) {
          return Column(children: [first, second]);
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 12),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Widget _formHeader() => AppPageHeader(
    title: widget.vehiculo != null
        ? 'Actualizar vehículo'
        : 'Registrar vehículo',
    subtitle: widget.vehiculo != null
        ? 'Modifica los datos operativos y comerciales.'
        : 'Completa la información para agregarlo a tu flota.',
    icon: Icons.directions_car_outlined,
  );

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) => AppSectionCard(
    title: title,
    subtitle: subtitle,
    icon: icon,
    child: child,
  );

  Widget _propertyDropdown() {
    return DropdownButtonFormField<TipoPropiedadVehiculo>(
      initialValue: _tipoPropiedad,
      decoration: _inputDecoration(
        'Tipo de propiedad',
        Icons.business_center_outlined,
      ),
      items: TipoPropiedadVehiculo.values
          .map((item) => DropdownMenuItem(value: item, child: Text(item.label)))
          .toList(growable: false),
      onChanged: (value) {
        if (value != null) setState(() => _tipoPropiedad = value);
      },
    );
  }

  Widget _actionBar(VehiculoProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: provider.isMutating ? null : () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
          label: const Text('Cancelar'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 17),
            backgroundColor: const Color(0xFF3867F4),
          ),
          onPressed: provider.isMutating ? null : _guardar,
          icon: provider.isMutating
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_rounded),
          label: Text(provider.isMutating ? 'Guardando…' : 'Guardar vehículo'),
        ),
      ],
    );
  }

  Widget _field(
    String key,
    String label, {
    bool numeric = false,
    bool required = true,
    int maxLines = 1,
    String? suffixText,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _fields[key],
        decoration: _inputDecoration(label, icon, suffixText: suffixText),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Campo obligatorio';
          }
          if (numeric &&
              value != null &&
              value.isNotEmpty &&
              num.tryParse(value) == null) {
            return 'Valor numérico no válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _catalogDropdown({
    required String label,
    required IconData icon,
    required int? value,
    required List<VehicleCatalogOption> options,
    required ValueChanged<int?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: _inputDecoration(label, icon),
        items: options
            .map(
              (option) => DropdownMenuItem<int>(
                value: option.id,
                child: Text(option.name),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
        validator: (selected) => selected == null ? 'Campo obligatorio' : null,
      ),
    );
  }

  Widget _currencyDropdown(VehicleCatalogProvider catalogs) {
    final value = _validValue(_idMoneda, catalogs.currencies);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        decoration: _inputDecoration(
          'Moneda de la tarifa',
          Icons.currency_exchange_rounded,
        ),
        items: catalogs.currencies
            .map(
              (option) => DropdownMenuItem<int>(
                value: option.id,
                child: Text(
                  '${option.code} · ${option.name} (${option.symbol})',
                ),
              ),
            )
            .toList(growable: false),
        onChanged: (selected) => setState(() => _idMoneda = selected),
        validator: (selected) => selected == null ? 'Campo obligatorio' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData? icon, {
    String? suffixText,
  }) => InputDecoration(
    labelText: label,
    prefixIcon: icon == null ? null : Icon(icon, size: 21),
    suffixText: suffixText,
  );

  Widget _catalogError(VehicleCatalogProvider catalogs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 12),
            Text(
              catalogs.errorMessage ?? 'No fue posible cargar los catálogos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => catalogs.load(force: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  static int? _validValue(
    int? current,
    Iterable<VehicleCatalogOption> options,
  ) => current != null && options.any((option) => option.id == current)
      ? current
      : null;

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final dto = VehiculoDto(
      idCombustible: _idCombustible!,
      idTransmision: _idTransmision!,
      idTipo: _idTipo!,
      tipoPropiedad: _tipoPropiedad,
      idProveedorVehiculo: _tipoPropiedad == TipoPropiedadVehiculo.tercero
          ? int.parse(_fields['proveedor']!.text)
          : null,
      idMonedaTarifa: _idMoneda!,
      marca: _fields['marca']!.text.trim(),
      modelo: _fields['modelo']!.text.trim(),
      anio: int.parse(_fields['anio']!.text),
      placa: _fields['placa']!.text.trim(),
      color: _fields['color']!.text.trim(),
      vin: _fields['vin']!.text.trim(),
      precioPorDia: double.parse(_fields['precio']!.text),
      kilometraje: int.parse(_fields['kilometraje']!.text),
      descripcion: _fields['descripcion']!.text.trim(),
      depositoCombustible: double.parse(_fields['deposito']!.text),
    );

    final current = widget.vehiculo;
    final success = current == null
        ? await context.read<VehiculoProvider>().crear(dto)
        : await context.read<VehiculoProvider>().actualizar(
            current.idVehiculo,
            dto,
          );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<VehiculoProvider>().errorMessage ??
              'No fue posible guardar el vehículo.',
        ),
      ),
    );
  }
}

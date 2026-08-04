import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo_dto.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehiculo;
    _tipoPropiedad = vehicle?.tipoPropiedad ?? TipoPropiedadVehiculo.propio;
    _fields = {
      'marca': TextEditingController(text: vehicle?.marca),
      'modelo': TextEditingController(text: vehicle?.modelo),
      'placa': TextEditingController(text: vehicle?.placa),
      'anio': TextEditingController(text: vehicle?.anio.toString()),
      'combustible': TextEditingController(
        text: vehicle?.idCombustible.toString(),
      ),
      'transmision': TextEditingController(
        text: vehicle?.idTransmision.toString(),
      ),
      'tipo': TextEditingController(text: vehicle?.idTipo.toString()),
      'moneda': TextEditingController(text: vehicle?.idMonedaTarifa.toString()),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehiculo == null ? 'Nuevo vehículo' : 'Editar vehículo',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Información general',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _responsiveRow(
              _field('marca', 'Marca'),
              _field('modelo', 'Modelo'),
            ),
            _responsiveRow(
              _field('placa', 'Placa'),
              _field('anio', 'Año', numeric: true),
            ),
            _responsiveRow(
              _field('vin', 'VIN', required: false),
              _field('color', 'Color', required: false),
            ),
            const SizedBox(height: 16),
            Text(
              'Clasificación y tarifa',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoPropiedadVehiculo>(
              initialValue: _tipoPropiedad,
              decoration: const InputDecoration(
                labelText: 'Tipo de propiedad',
                border: OutlineInputBorder(),
              ),
              items: TipoPropiedadVehiculo.values
                  .map(
                    (item) =>
                        DropdownMenuItem(value: item, child: Text(item.label)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _tipoPropiedad = value!),
            ),
            const SizedBox(height: 12),
            _responsiveRow(
              _field('combustible', 'ID combustible', numeric: true),
              _field('transmision', 'ID transmisión', numeric: true),
            ),
            _responsiveRow(
              _field('tipo', 'ID tipo', numeric: true),
              _field('moneda', 'ID moneda', numeric: true),
            ),
            if (_tipoPropiedad == TipoPropiedadVehiculo.tercero)
              _field('proveedor', 'ID proveedor', numeric: true),
            _responsiveRow(
              _field('precio', 'Precio por día', numeric: true),
              _field('deposito', 'Depósito', numeric: true),
            ),
            _field('kilometraje', 'Kilometraje', numeric: true),
            _field('descripcion', 'Descripción', required: false, maxLines: 3),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: provider.isMutating ? null : _guardar,
              icon: provider.isMutating
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(provider.isMutating ? 'Guardando…' : 'Guardar'),
            ),
          ],
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

  Widget _field(
    String key,
    String label, {
    bool numeric = false,
    bool required = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _fields[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
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

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final dto = VehiculoDto(
      idCombustible: int.parse(_fields['combustible']!.text),
      idTransmision: int.parse(_fields['transmision']!.text),
      idTipo: int.parse(_fields['tipo']!.text),
      tipoPropiedad: _tipoPropiedad,
      idProveedorVehiculo: _tipoPropiedad == TipoPropiedadVehiculo.tercero
          ? int.parse(_fields['proveedor']!.text)
          : null,
      idMonedaTarifa: int.parse(_fields['moneda']!.text),
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

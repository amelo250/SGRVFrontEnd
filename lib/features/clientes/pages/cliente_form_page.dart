import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente_dto.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';

class ClienteFormPage extends StatefulWidget {
  const ClienteFormPage({this.cliente, super.key});

  final Cliente? cliente;

  @override
  State<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends State<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  DateTime? _fechaNacimiento;
  DateTime? _fechaExpLicencia;
  DateTime? _fechaVencLicencia;

  @override
  void initState() {
    super.initState();
    final cliente = widget.cliente;
    _fechaNacimiento = cliente?.fechaNacimiento;
    _fechaExpLicencia = cliente?.fechaExpLicencia;
    _fechaVencLicencia = cliente?.fechaVencLicencia;
    _fields = {
      'nombre': TextEditingController(text: cliente?.nombre),
      'apellido': TextEditingController(text: cliente?.apellido),
      'documento': TextEditingController(text: cliente?.cedulaPasaporte),
      'telefono': TextEditingController(text: cliente?.telefono),
      'email': TextEditingController(text: cliente?.email),
      'direccion': TextEditingController(text: cliente?.direccion),
      'nacionalidad': TextEditingController(text: cliente?.nacionalidad),
      'licencia': TextEditingController(text: cliente?.licenciaConducir),
    };
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cliente == null ? 'Nuevo cliente' : 'Editar cliente',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _section(context, 'Información personal'),
              const SizedBox(height: 14),
              _row(_field('nombre', 'Nombre'), _field('apellido', 'Apellido')),
              _row(
                _field('documento', 'Cédula o pasaporte'),
                _dateField(
                  'Fecha de nacimiento',
                  _fechaNacimiento,
                  (value) => setState(() => _fechaNacimiento = value),
                  lastDate: DateTime.now(),
                ),
              ),
              _row(
                _field('telefono', 'Teléfono', required: false),
                _field(
                  'email',
                  'Correo electrónico',
                  required: false,
                  email: true,
                ),
              ),
              _row(
                _field('nacionalidad', 'Nacionalidad', required: false),
                _field('direccion', 'Dirección', required: false),
              ),
              const SizedBox(height: 18),
              _section(context, 'Licencia de conducir'),
              const SizedBox(height: 14),
              _field('licencia', 'Número de licencia'),
              _row(
                _dateField(
                  'Fecha de expedición',
                  _fechaExpLicencia,
                  (value) => setState(() => _fechaExpLicencia = value),
                  lastDate: DateTime.now(),
                ),
                _dateField(
                  'Fecha de vencimiento',
                  _fechaVencLicencia,
                  (value) => setState(() => _fechaVencLicencia = value),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                ),
              ),
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
      ),
    );
  }

  Widget _section(BuildContext context, String text) =>
      Text(text, style: Theme.of(context).textTheme.titleLarge);

  Widget _row(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (_, constraints) {
        if (constraints.maxWidth < 650) {
          return Column(children: [first, second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
    bool required = true,
    bool email = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _fields[key],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) {
          final text = value?.trim() ?? '';
          if (required && text.isEmpty) return 'Campo obligatorio';
          if (email &&
              text.isNotEmpty &&
              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
            return 'Correo electrónico no válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _dateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final selected = await showDatePicker(
            context: context,
            initialDate: _clampDate(
              value ?? DateTime.now(),
              firstDate ?? DateTime(1900),
              lastDate ?? DateTime.now().add(const Duration(days: 3650)),
            ),
            firstDate: firstDate ?? DateTime(1900),
            lastDate:
                lastDate ?? DateTime.now().add(const Duration(days: 3650)),
          );
          if (selected != null) onChanged(selected);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_month),
            errorText: value == null ? 'Campo obligatorio' : null,
          ),
          child: Text(value == null ? 'Seleccionar' : _formatDate(value)),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fechaNacimiento == null ||
        _fechaExpLicencia == null ||
        _fechaVencLicencia == null) {
      _message('Debes completar todas las fechas.');
      return;
    }
    if (!_fechaVencLicencia!.isAfter(_fechaExpLicencia!)) {
      _message('El vencimiento debe ser posterior a la expedición.');
      return;
    }

    final dto = ClienteDto(
      nombre: _fields['nombre']!.text,
      apellido: _fields['apellido']!.text,
      cedulaPasaporte: _fields['documento']!.text,
      fechaNacimiento: _fechaNacimiento!,
      telefono: _fields['telefono']!.text,
      email: _fields['email']!.text,
      direccion: _fields['direccion']!.text,
      nacionalidad: _fields['nacionalidad']!.text,
      licenciaConducir: _fields['licencia']!.text,
      fechaExpLicencia: _fechaExpLicencia!,
      fechaVencLicencia: _fechaVencLicencia!,
    );
    final provider = context.read<ClienteProvider>();
    final current = widget.cliente;
    final success = current == null
        ? await provider.crear(dto)
        : await provider.actualizar(current.idCliente, dto);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else {
      _message(provider.errorMessage ?? 'No fue posible guardar el cliente.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  static DateTime _clampDate(DateTime value, DateTime first, DateTime last) {
    if (value.isBefore(first)) return first;
    if (value.isAfter(last)) return last;
    return value;
  }

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

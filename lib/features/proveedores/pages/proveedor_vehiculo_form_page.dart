import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo_dto.dart';
import 'package:sgrv_frontend/features/proveedores/providers/proveedor_vehiculo_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class ProveedorVehiculoFormPage extends StatefulWidget {
  const ProveedorVehiculoFormPage({this.proveedor, super.key});

  final ProveedorVehiculo? proveedor;

  @override
  State<ProveedorVehiculoFormPage> createState() =>
      _ProveedorVehiculoFormPageState();
}

class _ProveedorVehiculoFormPageState extends State<ProveedorVehiculoFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombre;
  late final TextEditingController _rncCedula;
  late final TextEditingController _telefono;
  late final TextEditingController _direccion;
  late final TextEditingController _contacto;
  late final TextEditingController _observacion;
  late bool _activo;

  @override
  void initState() {
    super.initState();
    final proveedor = widget.proveedor;
    _nombre = TextEditingController(text: proveedor?.nombre);
    _rncCedula = TextEditingController(text: proveedor?.rncCedula);
    _telefono = TextEditingController(text: proveedor?.telefono);
    _direccion = TextEditingController(text: proveedor?.direccion);
    _contacto = TextEditingController(text: proveedor?.contacto);
    _observacion = TextEditingController(text: proveedor?.observacion);
    _activo = proveedor?.activo ?? true;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _rncCedula.dispose();
    _telefono.dispose();
    _direccion.dispose();
    _contacto.dispose();
    _observacion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProveedorVehiculoProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.proveedor == null ? 'Nuevo proveedor' : 'Editar proveedor',
        ),
      ),
      body: AppResponsiveContent(
        maxWidth: 920,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              AppPageHeader(
                title: widget.proveedor == null
                    ? 'Nuevo proveedor'
                    : 'Editar proveedor',
                subtitle:
                    'Información comercial y de contacto del propietario de vehículos.',
                icon: Icons.handshake_rounded,
              ),
              const SizedBox(height: 22),
              AppSectionCard(
                title: 'Datos del proveedor',
                subtitle: 'Completa los campos necesarios para identificarlo.',
                icon: Icons.business_center_outlined,
                child: Column(
                  children: [
                    _field(_nombre, 'Nombre', maxLength: 150),
                    _field(_rncCedula, 'RNC o cédula', maxLength: 20),
                    _field(
                      _telefono,
                      'Teléfono',
                      required: false,
                      maxLength: 20,
                      keyboardType: TextInputType.phone,
                    ),
                    _field(
                      _contacto,
                      'Persona de contacto',
                      required: false,
                      maxLength: 150,
                    ),
                    _field(
                      _direccion,
                      'Dirección',
                      required: false,
                      maxLength: 250,
                    ),
                    _field(
                      _observacion,
                      'Observación',
                      required: false,
                      maxLength: 500,
                      maxLines: 3,
                    ),
                    if (widget.proveedor != null)
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _activo,
                        onChanged: (value) => setState(() => _activo = value),
                        title: const Text(
                          'Proveedor activo',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: provider.isMutating ? null : _guardar,
                  icon: provider.isMutating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    provider.isMutating ? 'Guardando…' : 'Guardar proveedor',
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    int? maxLength,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return 'Campo obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    final dto = ProveedorVehiculoDto(
      nombre: _nombre.text.trim(),
      rncCedula: _rncCedula.text.trim(),
      telefono: _nullable(_telefono.text),
      direccion: _nullable(_direccion.text),
      contacto: _nullable(_contacto.text),
      observacion: _nullable(_observacion.text),
      activo: widget.proveedor == null ? null : _activo,
    );
    final provider = context.read<ProveedorVehiculoProvider>();
    final actual = widget.proveedor;
    final success = actual == null
        ? await provider.crear(dto)
        : await provider.actualizar(actual.idProveedorVehiculo, dto);
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ?? 'No fue posible guardar el proveedor.',
        ),
      ),
    );
  }

  String? _nullable(String value) {
    final normalized = value.trim();
    return normalized.isEmpty ? null : normalized;
  }
}

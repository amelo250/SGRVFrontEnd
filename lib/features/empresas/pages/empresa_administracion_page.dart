import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';

class EmpresaAdministracionPage extends StatefulWidget {
  const EmpresaAdministracionPage({this.empresa, super.key});
  final Empresa? empresa;
  @override
  State<EmpresaAdministracionPage> createState() =>
      _EmpresaAdministracionPageState();
}

class _EmpresaAdministracionPageState extends State<EmpresaAdministracionPage> {
  final _service = EmpresaService();
  final _form = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.empresa?.nombre);
  late final _comercial = TextEditingController(
    text: widget.empresa?.nombreComercial,
  );
  late final _rnc = TextEditingController(text: widget.empresa?.rnc);
  late final _telefono = TextEditingController(text: widget.empresa?.telefono);
  late final _correo = TextEditingController(text: widget.empresa?.correo);
  late final _direccion = TextEditingController(
    text: widget.empresa?.direccion,
  );
  late bool _activo = widget.empresa?.activo ?? true;
  int? _plan;
  bool _busy = false;
  late Future<List<Map<String, dynamic>>> _planes = _service.getPlanes();

  @override
  void dispose() {
    for (final c in [
      _nombre,
      _comercial,
      _rnc,
      _telefono,
      _correo,
      _direccion,
    ]) {
      c.dispose();
    }
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.empresa == null ? 'Nueva empresa' : 'Administrar empresa',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _field(_nombre, 'Nombre legal', 150),
              _field(_comercial, 'Nombre comercial', 150),
              _field(_rnc, 'RNC', 20),
              _field(_telefono, 'Teléfono', 20, required: false),
              _field(_correo, 'Correo', 150, required: false),
              _field(_direccion, 'Dirección', 250, required: false),
              if (widget.empresa != null)
                SwitchListTile(
                  title: const Text('Empresa activa'),
                  subtitle: const Text(
                    'Desactivar revoca el acceso de sus usuarios. Los datos se conservan.',
                  ),
                  value: _activo,
                  onChanged: _busy ? null : (v) => setState(() => _activo = v),
                ),
              if (widget.empresa != null)
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: const Text('Guardar información y estado'),
                ),
              const SizedBox(height: 24),
              Text(
                widget.empresa == null
                    ? 'Plan inicial'
                    : 'Plan actual: #${widget.empresa!.idPlan}',
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _planes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return TextButton(
                      onPressed: () =>
                          setState(() => _planes = _service.getPlanes()),
                      child: const Text('Reintentar cargar planes'),
                    );
                  }
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Plan comercial',
                    ),
                    isExpanded: true,
                    items: snapshot.data!
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: (p['idPlan'] as num).toInt(),
                            child: Text(
                              '${p['nombre']} · ${p['maxVehiculos']} vehículos',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _busy ? null : (v) => setState(() => _plan = v),
                  );
                },
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _busy || _plan == null
                    ? null
                    : widget.empresa == null
                    ? _save
                    : _changePlan,
                child: Text(
                  widget.empresa == null ? 'Crear empresa' : 'Cambiar plan',
                ),
              ),
              if (_busy) const LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _field(
    TextEditingController c,
    String label,
    int max, {
    bool required = true,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: c,
      enabled: !_busy,
      maxLength: max,
      decoration: InputDecoration(labelText: label),
      validator: (v) => required && (v == null || v.trim().isEmpty)
          ? 'Campo obligatorio.'
          : null,
    ),
  );

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await _run(
      () => _service.guardar(
        id: widget.empresa?.idEmpresa,
        datos: {
          'nombre': _nombre.text.trim(),
          'nombreComercial': _comercial.text.trim(),
          // Se conserva el contrato histórico del DTO de actualización.
          'nombtreComercial': _comercial.text.trim(), 'rnc': _rnc.text.trim(),
          'telefono': _telefono.text.trim(), 'correo': _correo.text.trim(),
          'direccion': _direccion.text.trim(), 'activo': _activo,
          if (widget.empresa == null) 'idPlan': _plan,
        },
      ),
    );
  }

  Future<void> _changePlan() =>
      _run(() => _service.cambiarPlan(widget.empresa!.idEmpresa, _plan!));

  Future<void> _run(Future<Empresa> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException
                  ? e.message
                  : 'No fue posible guardar la empresa.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

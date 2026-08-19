import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';
import '../models/usuario_admin.dart';
import '../services/usuarios_admin_service.dart';

class UsuarioAdminFormPage extends StatefulWidget {
  const UsuarioAdminFormPage({super.key});
  @override
  State<UsuarioAdminFormPage> createState() => _UsuarioAdminFormPageState();
}

class _UsuarioAdminFormPageState extends State<UsuarioAdminFormPage> {
  final _key = GlobalKey<FormState>();
  final _usuarios = UsuariosAdminService();
  final _empresasService = EmpresaService();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmacion = TextEditingController();
  List<Empresa> _empresas = const [];
  List<RolAdminOption> _roles = const [];
  int? _empresa, _rol;
  bool _loading = true, _saving = false, _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _empresasService.getEmpresas(),
        _usuarios.getRoles(),
      ]);
      _empresas = (results[0] as List<Empresa>).where((x) => x.activo).toList();
      _roles = results[1] as List<RolAdminOption>;
      if (_empresas.isNotEmpty) _empresa = _empresas.first.idEmpresa;
      if (_roles.isNotEmpty) _rol = _roles.first.id;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate() || _empresa == null || _rol == null) {
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _usuarios.create(
        nombre: _nombre.text,
        telefono: _telefono.text,
        idEmpresa: _empresa!,
        idRol: _rol!,
        email: _email.text,
        password: _password.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _email, _password, _confirmacion]) {
      c.dispose();
    }
    _usuarios.dispose();
    _empresasService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nuevo usuario')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _key,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Crear usuario de la aplicación',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Asigna la empresa y el rol que tendrá el nuevo usuario.',
                            ),
                            const SizedBox(height: 22),
                            _field(_nombre, 'Nombre completo'),
                            _field(
                              _telefono,
                              'Teléfono',
                              keyboard: TextInputType.phone,
                            ),
                            _field(
                              _email,
                              'Correo electrónico',
                              keyboard: TextInputType.emailAddress,
                              email: true,
                            ),
                            DropdownButtonFormField<int>(
                              initialValue: _empresa,
                              decoration: const InputDecoration(
                                labelText: 'Empresa',
                                border: OutlineInputBorder(),
                              ),
                              items: _empresas
                                  .map(
                                    (x) => DropdownMenuItem(
                                      value: x.idEmpresa,
                                      child: Text(
                                        x.nombreComercial.isEmpty
                                            ? x.nombre
                                            : x.nombreComercial,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _empresa = v),
                              validator: (v) =>
                                  v == null ? 'Selecciona una empresa' : null,
                            ),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<int>(
                              initialValue: _rol,
                              decoration: const InputDecoration(
                                labelText: 'Rol',
                                border: OutlineInputBorder(),
                              ),
                              items: _roles
                                  .map(
                                    (x) => DropdownMenuItem(
                                      value: x.id,
                                      child: Text('${x.nombre} (${x.codigo})'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _rol = v),
                              validator: (v) =>
                                  v == null ? 'Selecciona un rol' : null,
                            ),
                            const SizedBox(height: 14),
                            _passwordField(_password, 'Contraseña'),
                            _passwordField(
                              _confirmacion,
                              'Confirmar contraseña',
                              confirmation: true,
                            ),
                            if (_error != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.person_add_rounded),
                              label: const Text('Crear usuario'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
  );
  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboard,
    bool email = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return 'Campo obligatorio';
        if (email && (!value.contains('@') || !value.contains('.'))) {
          return 'Correo no válido';
        }
        return null;
      },
    ),
  );
  Widget _passwordField(
    TextEditingController controller,
    String label, {
    bool confirmation = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: _hidePassword,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidePassword = !_hidePassword),
          icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (v) {
        if ((v ?? '').length < 8) return 'Usa al menos 8 caracteres';
        if (confirmation && v != _password.text) {
          return 'Las contraseñas no coinciden';
        }
        return null;
      },
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/auth/pages/password_page.dart';
import '../models/usuario_admin.dart';
import '../services/usuarios_admin_service.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import 'usuario_admin_form_page.dart';

class UsuariosAdminPage extends StatefulWidget {
  const UsuariosAdminPage({super.key});
  @override
  State<UsuariosAdminPage> createState() => _UsuariosAdminPageState();
}

class _UsuariosAdminPageState extends State<UsuariosAdminPage> {
  final _service = UsuariosAdminService();
  List<UsuarioAdmin> _items = const [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _items = await _service.getAll();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(UsuarioAdmin item) async {
    try {
      await _service.setActive(item.idUsuario, !item.activo);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppModuleScaffold(
    title: 'Usuarios de la aplicación',
    subtitle: '${_items.length} usuarios en todas las empresas',
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final created = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const UsuarioAdminFormPage()),
        );
        if (created == true) await _load();
      },
      icon: const Icon(Icons.person_add_rounded),
      label: const Text('Nuevo usuario'),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? AppStateView(
            icon: Icons.error_outline,
            title: 'No fue posible cargar usuarios',
            message: _error,
            onRetry: _load,
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final item = _items[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        item.nombre.isEmpty
                            ? '?'
                            : item.nombre[0].toUpperCase(),
                      ),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${item.email} · Empresa #${item.idEmpresa} · Rol #${item.idRol}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (context.watch<AuthProvider>().isSuperAdmin)
                          IconButton(
                            tooltip: 'Restablecer contraseña',
                            icon: const Icon(Icons.lock_reset),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PasswordPage(
                                  mode: PasswordMode.reset,
                                  userId: item.idUsuario,
                                  companyId: item.idEmpresa,
                                  userName: item.nombre,
                                ),
                              ),
                            ),
                          ),
                        Switch(
                          value: item.activo,
                          onChanged: (_) => _toggle(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
  );
}

import 'package:flutter/material.dart';
import 'package:sgrv_frontend/shared/widgets/app_version.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/shared/theme/theme_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_logo.dart';
import 'password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _ocultarContrasena = true;

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;
    await auth.login(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appearance = context.watch<ThemeProvider>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 1000 && constraints.maxHeight >= 640;
            final form = SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth < 420 ? 16 : 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton.outlined(
                          tooltip: appearance.isDarkMode
                              ? 'Activar tema claro'
                              : 'Activar tema oscuro',
                          onPressed: () =>
                              appearance.setDarkMode(!appearance.isDarkMode),
                          icon: Icon(
                            appearance.isDarkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(
                            constraints.maxWidth < 420 ? 20 : 32,
                          ),
                          child: AutofillGroup(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppLogo(
                                    compact: true,
                                    color: scheme.onSurface,
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Bienvenido de vuelta',
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -.5,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ingresa tus credenciales para continuar.',
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  TextFormField(
                                    controller: _correoController,
                                    enabled: !auth.isLoading,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    autofillHints: const [
                                      AutofillHints.email,
                                      AutofillHints.username,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Correo electrónico',
                                      hintText: 'usuario@rentcar.com',
                                      prefixIcon: Icon(
                                        Icons.mail_outline_rounded,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Introduce el correo.';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Introduce un correo válido.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _contrasenaController,
                                    enabled: !auth.isLoading,
                                    obscureText: _ocultarContrasena,
                                    textInputAction: TextInputAction.done,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onFieldSubmitted: (_) => _iniciarSesion(),
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline_rounded,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _ocultarContrasena
                                            ? 'Mostrar contraseña'
                                            : 'Ocultar contraseña',
                                        onPressed: () => setState(
                                          () => _ocultarContrasena =
                                              !_ocultarContrasena,
                                        ),
                                        icon: Icon(
                                          _ocultarContrasena
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Introduce la contraseña.'
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: auth.isLoading
                                          ? null
                                          : () => Navigator.push(
                                              context,
                                              MaterialPageRoute<void>(
                                                builder: (_) =>
                                                    const PasswordPage(),
                                              ),
                                            ),
                                      child: const Text(
                                        '¿Olvidaste tu contraseña?',
                                      ),
                                    ),
                                  ),
                                  if (auth.errorMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: scheme.errorContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        auth.errorMessage!,
                                        style: TextStyle(
                                          color: scheme.onErrorContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  FilledButton.icon(
                                    onPressed: auth.isLoading
                                        ? null
                                        : _iniciarSesion,
                                    icon: auth.isLoading
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 18,
                                          ),
                                    label: Text(
                                      auth.isLoading
                                          ? 'Ingresando…'
                                          : 'Iniciar sesión',
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.shield_outlined,
                                        size: 16,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Acceso seguro',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'SGRV · Sistema de Gestión de Rent Car\nBy Nicoretech',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const AppVersion(),
                    ],
                  ),
                ),
              ),
            );
            return Row(
              children: [
                if (wide)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(48),
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        border: Border.all(color: scheme.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppLogo(compact: true, color: scheme.onSurface),
                          const Spacer(),
                          Icon(
                            Icons.directions_car_outlined,
                            size: 72,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 32),
                          Text(
                            'Tu flota.\nTodo bajo control.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Reservaciones, rentas y finanzas en un solo lugar.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              Chip(
                                avatar: Icon(Icons.event_outlined, size: 16),
                                label: Text('Reservaciones'),
                              ),
                              Chip(
                                avatar: Icon(
                                  Icons.directions_car_outlined,
                                  size: 16,
                                ),
                                label: Text('Flota'),
                              ),
                              Chip(
                                avatar: Icon(Icons.insights_outlined, size: 16),
                                label: Text('Finanzas'),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Gestión simple para cada operación.',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(child: Center(child: form)),
              ],
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/dashboard/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _ocultarContrasena = true;
  bool _recordarme = false;

  static const Color _primaryColor = Color(0xFF3867F4);
  static const Color _secondaryColor = Color(0xFF7057F5);
  static const Color _textColor = Color(0xFF172033);
  static const Color _mutedColor = Color(0xFF7B8498);
  static const Color _backgroundColor = Color(0xFFF5F7FB);
  static const Color _borderColor = Color(0xFFE7EBF2);

  Future<void> _iniciarSesion() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final loginCorrecto = await authProvider.login(
      correo: _correoController.text.trim(),
      contrasena: _contrasenaController.text,
    );

    if (!mounted) {
      return;
    }

    if (loginCorrecto) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool mostrarPanelVisual = constraints.maxWidth >= 900;

          return Row(
            children: [
              if (mostrarPanelVisual)
                const Expanded(flex: 11, child: _PanelVisual()),
              Expanded(
                flex: mostrarPanelVisual ? 9 : 1,
                child: _PanelFormulario(
                  formKey: _formKey,
                  correoController: _correoController,
                  contrasenaController: _contrasenaController,
                  ocultarContrasena: _ocultarContrasena,
                  recordarme: _recordarme,
                  authProvider: authProvider,
                  onCambiarVisibilidad: () {
                    setState(() {
                      _ocultarContrasena = !_ocultarContrasena;
                    });
                  },
                  onRecordarmeChanged: (value) {
                    setState(() {
                      _recordarme = value ?? false;
                    });
                  },
                  onLogin: _iniciarSesion,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PanelVisual extends StatelessWidget {
  const _PanelVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(56),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF061123), Color(0xFF123A62), Color(0xFF1977B6)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -100,
            bottom: -110,
            child: Container(
              width: 430,
              height: 430,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -140,
            top: 100,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7057F5).withValues(alpha: 0.15),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _LogoSGRV(textoColor: Colors.white),
              const Spacer(),
              Center(
                child: Container(
                  width: 320,
                  height: 230,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        bottom: 30,
                        child: Container(
                          width: 230,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.black.withValues(alpha: 0.18),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.directions_car_filled_rounded,
                        size: 170,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 42),
              const Text(
                'Administra tu rent car\ndesde cualquier lugar.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Gestiona reservas, vehículos, clientes, pagos y reportes '
                'desde una experiencia moderna y sencilla.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.76),
                  fontSize: 17,
                  height: 1.55,
                ),
              ),
              const Spacer(),
              Text(
                'Sistema de Gestión de Rent Car',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.60),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelFormulario extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController correoController;
  final TextEditingController contrasenaController;
  final bool ocultarContrasena;
  final bool recordarme;
  final AuthProvider authProvider;
  final VoidCallback onCambiarVisibilidad;
  final ValueChanged<bool?> onRecordarmeChanged;
  final VoidCallback onLogin;

  const _PanelFormulario({
    required this.formKey,
    required this.correoController,
    required this.contrasenaController,
    required this.ocultarContrasena,
    required this.recordarme,
    required this.authProvider,
    required this.onCambiarVisibilidad,
    required this.onRecordarmeChanged,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _LoginPageState._backgroundColor,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 34),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _LoginPageState._borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12091E42),
                    blurRadius: 35,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _LogoSGRV(
                      compacto: true,
                      textoColor: _LoginPageState._textColor,
                    ),
                    const SizedBox(height: 38),
                    const Text(
                      'Bienvenido de vuelta',
                      style: TextStyle(
                        color: _LoginPageState._textColor,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa tus credenciales para continuar.',
                      style: TextStyle(
                        color: _LoginPageState._mutedColor,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Correo electrónico',
                      style: TextStyle(
                        color: _LoginPageState._textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.email,
                        AutofillHints.username,
                      ],
                      decoration: _inputDecoration(
                        hintText: 'usuario@rentcar.com',
                        prefixIcon: Icons.mail_outline_rounded,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Introduce el correo.';
                        }

                        if (!value.contains('@')) {
                          return 'Introduce un correo válido.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: _LoginPageState._textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextFormField(
                      controller: contrasenaController,
                      obscureText: ocultarContrasena,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) {
                        if (!authProvider.isLoading) {
                          onLogin();
                        }
                      },
                      decoration: _inputDecoration(
                        hintText: 'Introduce tu contraseña',
                        prefixIcon: Icons.lock_outline_rounded,
                        suffixIcon: IconButton(
                          onPressed: onCambiarVisibilidad,
                          tooltip: ocultarContrasena
                              ? 'Mostrar contraseña'
                              : 'Ocultar contraseña',
                          icon: Icon(
                            ocultarContrasena
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _LoginPageState._mutedColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce la contraseña.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Checkbox(
                          value: recordarme,
                          onChanged: onRecordarmeChanged,
                          activeColor: _LoginPageState._primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Recordarme',
                          style: TextStyle(
                            color: _LoginPageState._textColor,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'La recuperación de contraseña '
                                        'se implementará próximamente.',
                                      ),
                                    ),
                                  );
                                },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (authProvider.errorMessage != null) ...[
                      const SizedBox(height: 8),
                      _MensajeError(mensaje: authProvider.errorMessage!),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: authProvider.isLoading ? null : onLogin,
                        style: FilledButton.styleFrom(
                          backgroundColor: _LoginPageState._primaryColor,
                          disabledBackgroundColor: _LoginPageState._primaryColor
                              .withValues(alpha: 0.55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Iniciar sesión',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(color: _LoginPageState._borderColor),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 16,
                                color: _LoginPageState._mutedColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Acceso seguro',
                                style: TextStyle(
                                  color: _LoginPageState._mutedColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Divider(color: _LoginPageState._borderColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        '© 2026 SGRV Rent Car',
                        style: TextStyle(
                          color: _LoginPageState._mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFFA5ADBD), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _LoginPageState._mutedColor),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _LoginPageState._borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _LoginPageState._borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: _LoginPageState._primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE94B4B)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE94B4B), width: 1.5),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  final String mensaje;

  const _MensajeError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD1D1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE94B4B),
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoSGRV extends StatelessWidget {
  final bool compacto;
  final Color textoColor;

  const _LogoSGRV({this.compacto = false, required this.textoColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compacto ? 42 : 52,
          height: compacto ? 42 : 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_LoginPageState._secondaryColor, Color(0xFF2F9DFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: _LoginPageState._primaryColor.withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: Colors.white,
            size: compacto ? 25 : 31,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SGRV',
              style: TextStyle(
                color: textoColor,
                fontSize: compacto ? 21 : 31,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'RENT CAR',
              style: TextStyle(
                color: compacto
                    ? _LoginPageState._primaryColor
                    : const Color(0xFF58B8FF),
                fontSize: compacto ? 9 : 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

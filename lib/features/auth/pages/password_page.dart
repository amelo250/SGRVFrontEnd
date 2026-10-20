import 'package:flutter/material.dart';
import '../services/password_service.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';

enum PasswordMode { recovery, change, reset }

class PasswordPage extends StatefulWidget {
  const PasswordPage({
    super.key,
    this.mode = PasswordMode.recovery,
    this.userId,
    this.companyId,
    this.userName,
  });
  final PasswordMode mode;
  final int? userId;
  final int? companyId;
  final String? userName;
  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final _service = PasswordService();
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _busy = false;
  bool _enterCode = false;
  String? _message;
  bool get _recovery => widget.mode == PasswordMode.recovery;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      if (_recovery && !_enterCode) {
        final message = await _service.request(_email.text);
        if (!mounted) return;
        setState(() {
          _enterCode = true;
          _message = message;
        });
      } else if (_recovery) {
        final message = await _service.recover(
          _code.text,
          _password.text,
          _confirmation.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context);
      } else {
        if (widget.mode == PasswordMode.change) {
          await _service.change(
            _current.text,
            _password.text,
            _confirmation.text,
          );
        } else {
          await _service.reset(
            widget.userId!,
            widget.companyId!,
            _password.text,
            _confirmation.text,
          );
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Contraseña actualizada. El usuario debe iniciar sesión nuevamente.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = error is ApiException
              ? error.message
              : 'No fue posible conectar con el servicio. Inténtalo nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _email,
      _code,
      _current,
      _password,
      _confirmation,
    ]) {
      controller.dispose();
    }
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        _recovery
            ? 'Recuperar contraseña'
            : widget.mode == PasswordMode.change
            ? 'Cambiar mi contraseña'
            : 'Restablecer contraseña',
      ),
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _recovery
                      ? 'Recuperación para administradores. Recibirás un código por correo, válido durante 15 minutos.'
                      : widget.mode == PasswordMode.change
                      ? 'Al guardar se cerrará tu sesión.'
                      : 'Usuario: ${widget.userName ?? widget.userId}\nEmpresa #${widget.companyId}. Se invalidarán sus sesiones anteriores.',
                ),
                const SizedBox(height: 20),
                if (_recovery && !_enterCode)
                  TextFormField(
                    controller: _email,
                    enabled: !_busy,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo registrado',
                    ),
                    validator: (v) =>
                        v == null || !v.contains('@') || v.trim().length > 100
                        ? 'Introduce un correo válido.'
                        : null,
                  ),
                if (_recovery && _enterCode)
                  TextFormField(
                    controller: _code,
                    enabled: !_busy,
                    maxLines: 3,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Código recibido por correo',
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Copia el código del correo.'
                        : null,
                  ),
                if (widget.mode == PasswordMode.change)
                  _secret(_current, 'Contraseña actual', current: true),
                if (!_recovery || _enterCode) ...[
                  _secret(_password, 'Nueva contraseña'),
                  _secret(
                    _confirmation,
                    'Confirmar contraseña',
                    confirmation: true,
                  ),
                ],
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(_message!),
                  ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _submit,
                  child: Text(
                    _busy
                        ? 'Procesando…'
                        : _recovery && !_enterCode
                        ? 'Enviar instrucciones'
                        : 'Guardar contraseña',
                  ),
                ),
                if (_recovery)
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                            _enterCode = !_enterCode;
                            _message = null;
                          }),
                    child: Text(
                      _enterCode
                          ? 'Solicitar otro código'
                          : 'Ya tengo un código',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _secret(
    TextEditingController controller,
    String label, {
    bool current = false,
    bool confirmation = false,
  }) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: TextFormField(
      controller: controller,
      enabled: !_busy,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Campo obligatorio.';
        if (value.length > 128 || (!current && value.length < 8)) {
          return 'Usa entre 8 y 128 caracteres.';
        }
        if (confirmation && value != _password.text) {
          return 'Las contraseñas no coinciden.';
        }
        return null;
      },
    ),
  );
}

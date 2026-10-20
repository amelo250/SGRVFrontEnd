import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/notificaciones/dtos/notificacion_resultado_dto.dart';
import 'package:sgrv_frontend/features/notificaciones/services/notificacion_service.dart';

class ContratoNotificacionDialog extends StatefulWidget {
  const ContratoNotificacionDialog({
    required this.rentaId,
    this.service,
    super.key,
  });
  final int rentaId;
  final NotificacionService? service;
  @override
  State<ContratoNotificacionDialog> createState() =>
      _ContratoNotificacionDialogState();
}

class _ContratoNotificacionDialogState
    extends State<ContratoNotificacionDialog> {
  late final NotificacionService _service;
  bool _email = true,
      _whatsapp = false,
      _client = true,
      _company = true,
      _busy = false,
      _sent = false;
  String? _error;
  List<NotificacionResultadoDto> _results = [];
  bool get _canSend =>
      !_busy && !_sent && _results.any((x) => x.estado == 'SIMULADO');
  @override
  void initState() {
    super.initState();
    _service = widget.service ?? NotificacionService();
  }

  @override
  void dispose() {
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  void _change(VoidCallback change) => setState(() {
    change();
    _results = [];
    _error = null;
  });
  Future<void> _process(bool simulate) async {
    if ((!_email && !_whatsapp) || (!_client && !_company)) {
      setState(() => _error = 'Selecciona un canal y un destinatario.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final results = await _service.contrato(
        widget.rentaId,
        correo: _email,
        whatsapp: _whatsapp,
        cliente: _client,
        empresa: _company,
        simular: simulate,
      );
      if (mounted) {
        setState(() {
          _results = results;
          _sent = !simulate;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: AlertDialog(
      title: const Text('Enviar contrato'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Se enviará el PDF guardado en Entrega y firmas a los contactos registrados. Revisa los canales antes de enviar.',
              ),
              CheckboxListTile(
                title: const Text('Correo electrónico'),
                value: _email,
                onChanged: _busy || _sent
                    ? null
                    : (v) => _change(() => _email = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('WhatsApp'),
                value: _whatsapp,
                onChanged: _busy || _sent
                    ? null
                    : (v) => _change(() => _whatsapp = v ?? false),
              ),
              const Divider(),
              CheckboxListTile(
                title: const Text('Cliente'),
                value: _client,
                onChanged: _busy || _sent
                    ? null
                    : (v) => _change(() => _client = v ?? false),
              ),
              CheckboxListTile(
                title: const Text('Empresa'),
                value: _company,
                onChanged: _busy || _sent
                    ? null
                    : (v) => _change(() => _company = v ?? false),
              ),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ..._results.map(
                (r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${r.destinatario == 'CLIENTE' ? 'Cliente' : 'Empresa'} · ${r.canal == 'CORREO' ? 'Correo' : 'WhatsApp'}',
                  ),
                  subtitle: Text('${r.estadoDescripcion}\n${r.mensaje}'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        if (!_sent)
          OutlinedButton(
            onPressed: _busy ? null : () => _process(true),
            child: const Text('Revisar envío'),
          ),
        if (!_sent)
          FilledButton(
            onPressed: _canSend ? () => _process(false) : null,
            child: const Text('Enviar'),
          ),
      ],
    ),
  );
}

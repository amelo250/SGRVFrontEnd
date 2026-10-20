import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/configuracion/services/condiciones_contrato_service.dart';

class CondicionesContratoPanel extends StatefulWidget {
  const CondicionesContratoPanel({super.key});
  @override
  State<CondicionesContratoPanel> createState() =>
      _CondicionesContratoPanelState();
}

class _CondicionesContratoPanelState extends State<CondicionesContratoPanel> {
  final _service = CondicionesContratoService();
  final _text = TextEditingController();
  String _expected = '';
  String? _error;
  bool _busy = true;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await _service.get();
      if (!mounted) return;
      _expected = value;
      _text.text = value;
      _loaded = true;
    } catch (error) {
      if (mounted) {
        _error = error is ApiException
            ? error.message
            : 'No fue posible cargar las condiciones.';
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final value = await _service.save(_text.text, _expected);
      if (!mounted) return;
      _expected = value;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Condiciones guardadas.')));
    } catch (error) {
      if (mounted) {
        _error = error is ApiException
            ? error.message
            : 'No fue posible guardar las condiciones.';
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Condiciones del contrato',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Estas condiciones se incluirán en los contratos que se generen.',
          ),
          const SizedBox(height: 12),
          if (_busy) const LinearProgressIndicator(),
          TextField(
            controller: _text,
            enabled: _loaded && !_busy,
            minLines: 5,
            maxLines: 12,
            maxLength: 12000,
            decoration: const InputDecoration(
              labelText: 'Condiciones personalizadas',
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(
                onPressed: _loaded && !_busy ? _save : null,
                child: const Text('Guardar condiciones'),
              ),
              TextButton(
                onPressed: _busy ? null : _load,
                child: const Text('Recargar'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  @override
  void dispose() {
    _text.dispose();
    _service.dispose();
    super.dispose();
  }
}

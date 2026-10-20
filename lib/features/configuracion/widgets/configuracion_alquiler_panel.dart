import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/configuracion/services/configuracion_alquiler_service.dart';

class ConfiguracionAlquilerPanel extends StatefulWidget {
  const ConfiguracionAlquilerPanel({super.key});
  @override
  State<ConfiguracionAlquilerPanel> createState() =>
      _ConfiguracionAlquilerPanelState();
}

class _ConfiguracionAlquilerPanelState
    extends State<ConfiguracionAlquilerPanel> {
  final _service = ConfiguracionAlquilerService();
  bool? _capture;
  bool _busy = false;
  String? _error;
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
      if (mounted) setState(() => _capture = value);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo cargar la configuración del alquiler.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save(bool value) async {
    if (_busy || _capture == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await _service.save(value, _capture!);
      if (mounted) {
        setState(() => _capture = saved);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Preferencia de alquiler guardada para esta empresa.',
            ),
          ),
        );
      }
    } catch (error) {
      // Recarga ante conflictos; nunca presenta un cambio local como guardado.
      try {
        final current = await _service.get();
        if (mounted) setState(() => _capture = current);
      } catch (_) {}
      if (mounted) {
        setState(() => _error = 'No se guardó la preferencia. $error');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        SwitchListTile(
          title: const Text('Capturar horas del periodo de alquiler'),
          subtitle: const Text(
            'Aplica a nuevas rentas y reservaciones de esta empresa. Al desactivarlo se reservan días completos; las horas reales de entrega y recepción se mantienen.',
          ),
          value: _capture ?? true,
          onChanged: _busy || _capture == null ? null : _save,
        ),
        if (_busy) const LinearProgressIndicator(),
        if (_error != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(_error!)),
        if (_capture == null && !_busy)
          TextButton(onPressed: _load, child: const Text('Reintentar')),
      ],
    ),
  );
}

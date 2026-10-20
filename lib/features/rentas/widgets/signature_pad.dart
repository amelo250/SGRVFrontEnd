import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// The form only previews committed signatures; drawing happens in a dialog.
class SignaturePad extends StatefulWidget {
  const SignaturePad({required this.label, super.key});

  final String label;

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  Uint8List? _savedPng;
  bool _opening = false;

  bool get isEmpty => _savedPng == null;

  void clear() => setState(() => _savedPng = null);

  Future<Uint8List?> exportPng() async => _savedPng;

  Future<void> _openPanel() async {
    if (_opening) return;
    _opening = true;
    try {
      final result = await showDialog<Uint8List>(
        context: context,
        barrierDismissible: false,
        builder: (_) =>
            _SignatureDialog(label: widget.label, initialPng: _savedPng),
      );
      if (mounted && result != null) setState(() => _savedPng = result);
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: '${isEmpty ? 'Firmar' : 'Editar'}: ${widget.label}',
          child: Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: colors.outline),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _openPanel,
              child: SizedBox(
                height: 150,
                child: isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.draw_outlined, color: colors.primary),
                          const SizedBox(height: 10),
                          Text(
                            'Firmar',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Abrir panel de firma',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          ColoredBox(
                            color: Colors.white,
                            child: Image.memory(
                              _savedPng!,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const Positioned(
                            right: 8,
                            bottom: 8,
                            child: Chip(
                              avatar: Icon(Icons.edit_outlined, size: 16),
                              label: Text('Editar firma'),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignatureDialog extends StatefulWidget {
  const _SignatureDialog({required this.label, required this.initialPng});
  final String label;
  final Uint8List? initialPng;

  @override
  State<_SignatureDialog> createState() => _SignatureDialogState();
}

class _SignatureDialogState extends State<_SignatureDialog> {
  final _boundaryKey = GlobalKey();
  // Normalized coordinates preserve stroke placement on viewport rotation.
  final List<Offset?> _points = [];
  late Uint8List? _initialPng = widget.initialPng;
  bool _saving = false;
  String? _error;

  bool get _hasStroke {
    for (var i = 0; i < _points.length - 1; i++) {
      if (_points[i] != null &&
          _points[i + 1] != null &&
          _points[i] != _points[i + 1]) {
        return true;
      }
    }
    return false;
  }

  bool get _empty => _initialPng == null && !_hasStroke;

  void _clear() => setState(() {
    _points.clear();
    _initialPng = null;
    _error = null;
  });

  void _add(Offset position, Size size) => setState(() {
    _error = null;
    _points.add(
      Offset(
        (position.dx / size.width).clamp(0.0, 1.0),
        (position.dy / size.height).clamp(0.0, 1.0),
      ),
    );
  });

  Future<void> _save() async {
    if (_saving) return;
    if (_empty) {
      setState(() => _error = 'Debe dibujar una firma antes de guardar.');
      return;
    }
    setState(() => _saving = true);
    try {
      Uint8List? png = _initialPng;
      if (_hasStroke) {
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        final boundary =
            _boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3);
        try {
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          png = data?.buffer.asUint8List();
        } finally {
          image.dispose();
        }
      }
      if (png == null) {
        throw StateError('No se pudo exportar la firma');
      }
      if (!mounted) return;
      // Re-enable pop before returning the successfully exported signature.
      setState(() => _saving = false);
      await WidgetsBinding.instance.endOfFrame;
      if (mounted) Navigator.of(context).pop(png);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo guardar la firma. Intente nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final mobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final fullscreen =
        size.width < 700 || (mobilePlatform && size.shortestSide < 600);
    final colors = Theme.of(context).colorScheme;
    final content = SafeArea(
      key: const ValueKey('signature-dialog-content'),
      child: Padding(
        padding: EdgeInsets.all(fullscreen ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.draw_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Cancelar firma',
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Firme dentro del recuadro y presione Guardar firma.',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AbsorbPointer(
                absorbing: _saving,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final canvasSize = constraints.biggest;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: RepaintBoundary(
                        key: _boundaryKey,
                        child: ColoredBox(
                          color: Colors.white,
                          child: GestureDetector(
                            key: const ValueKey('signature-canvas'),
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) =>
                                _add(details.localPosition, canvasSize),
                            onPanUpdate: (details) =>
                                _add(details.localPosition, canvasSize),
                            onPanEnd: (_) => setState(() => _points.add(null)),
                            onPanCancel: () =>
                                setState(() => _points.add(null)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (_initialPng != null)
                                  Image.memory(
                                    _initialPng!,
                                    fit: BoxFit.contain,
                                  ),
                                CustomPaint(
                                  painter: _SignaturePainter(List.of(_points)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: colors.error),
                semanticsLabel: _error,
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _clear,
                  icon: const Icon(Icons.cleaning_services_outlined, size: 18),
                  label: const Text('Limpiar'),
                ),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check, size: 18),
                  label: Text(_saving ? 'Guardando…' : 'Guardar firma'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return PopScope(
      canPop: !_saving,
      child: fullscreen
          ? Dialog.fullscreen(child: content)
          : Dialog(
              insetPadding: const EdgeInsets.all(24),
              child: SizedBox(width: 900, height: 640, child: content),
            ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  const _SignaturePainter(this.points);
  final List<Offset?> points;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF172033)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      if (start != null && end != null) {
        canvas.drawLine(
          Offset(start.dx * size.width, start.dy * size.height),
          Offset(end.dx * size.width, end.dy * size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({required this.label, super.key}) : _expanded = false;

  const SignaturePad._expanded({required this.label, super.key})
    : _expanded = true;

  final bool _expanded;

  final String label;

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final _boundaryKey = GlobalKey();
  final List<Offset?> _points = [];

  Uint8List? _savedPng;
  bool _opening = false;

  bool get _mobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool get isEmpty =>
      _savedPng == null && _points.whereType<Offset>().length < 2;

  void clear() => setState(() {
    _points.clear();
    _savedPng = null;
  });

  Future<void> _openPanel() async {
    if (_opening) return;
    _opening = true;
    try {
      final result = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => _SignaturePanel(label: widget.label),
        ),
      );
      if (mounted && result != null) {
        setState(() {
          _savedPng = result;
          _points.clear();
        });
      }
    } finally {
      _opening = false;
    }
  }

  Future<Uint8List?> exportPng() async {
    if (_savedPng != null) return _savedPng;
    if (isEmpty) return null;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          TextButton.icon(
            onPressed: clear,
            icon: const Icon(Icons.cleaning_services_outlined, size: 18),
            label: const Text('Limpiar'),
          ),
        ],
      ),
      if (widget._expanded) Expanded(child: _canvas()) else _canvas(),
    ],
  );

  Widget _canvas() => RepaintBoundary(
    key: _boundaryKey,
    child: Container(
      height: widget._expanded ? null : 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DEEA)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _mobile && !widget._expanded
          ? InkWell(
              onTap: _openPanel,
              child: _savedPng == null
                  ? const Center(
                      child: Text('Toque para firmar en pantalla completa'),
                    )
                  : Image.memory(_savedPng!, fit: BoxFit.contain),
            )
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (details) =>
                  setState(() => _points.add(details.localPosition)),
              onPanUpdate: (details) =>
                  setState(() => _points.add(details.localPosition)),
              onPanEnd: (_) => setState(() => _points.add(null)),
              child: CustomPaint(
                painter: _SignaturePainter(_points),
                child: isEmpty
                    ? const Center(
                        child: Text(
                          'Firme dentro de este recuadro',
                          style: TextStyle(color: Color(0xFF8A93A5)),
                        ),
                      )
                    : null,
              ),
            ),
    ),
  );
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
    for (var index = 0; index < points.length - 1; index++) {
      final start = points[index];
      final end = points[index + 1];
      if (start != null && end != null) canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}

class _SignaturePanel extends StatefulWidget {
  const _SignaturePanel({required this.label});
  final String label;

  @override
  State<_SignaturePanel> createState() => _SignaturePanelState();
}

class _SignaturePanelState extends State<_SignaturePanel> {
  final _padKey = GlobalKey<SignaturePadState>();
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    if (_padKey.currentState?.isEmpty ?? true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe dibujar una firma antes de guardar.'),
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final png = await _padKey.currentState?.exportPng();
      if (mounted && png != null) Navigator.of(context).pop(png);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar la firma. Intente nuevamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(widget.label),
      leading: IconButton(
        tooltip: 'Volver',
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back),
      ),
      actions: [
        TextButton.icon(
          onPressed: _saving ? null : _save,
          icon: const Icon(Icons.check),
          label: Text(_saving ? 'Guardando...' : 'Guardar'),
        ),
      ],
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: _saving,
          child: SignaturePad._expanded(key: _padKey, label: widget.label),
        ),
      ),
    ),
  );
}

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SignaturePad extends StatefulWidget {
  const SignaturePad({required this.label, super.key});

  final String label;

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final _boundaryKey = GlobalKey();
  final List<Offset?> _points = [];

  bool get isEmpty => _points.whereType<Offset>().length < 2;

  void clear() => setState(_points.clear);

  Future<Uint8List?> exportPng() async {
    if (isEmpty) return null;
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
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
      RepaintBoundary(
        key: _boundaryKey,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD8DEEA)),
          ),
          clipBehavior: Clip.antiAlias,
          child: GestureDetector(
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
      ),
    ],
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

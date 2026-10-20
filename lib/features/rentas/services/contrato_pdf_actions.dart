import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

/// Los bytes se obtienen autenticados; nunca se abre la URL privada en otro navegador.
Future<void> presentarContratoPdf(
  BuildContext context,
  Uint8List bytes, {
  required String filename,
  bool compartir = false,
}) async {
  try {
    if (bytes.length < 5 || String.fromCharCodes(bytes.take(5)) != '%PDF-') {
      throw StateError('El documento recibido no es un PDF.');
    }
    final info = await Printing.info();
    if (!context.mounted) return;
    if (compartir && info.canShare) {
      final box = context.findRenderObject();
      final bounds = box is RenderBox && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      await Printing.sharePdf(bytes: bytes, filename: filename, bounds: bounds);
    } else if (info.canPrint) {
      if (compartir) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Esta plataforma permite imprimir o guardar como PDF desde el diálogo.',
            ),
          ),
        );
      }
      await Printing.layoutPdf(name: filename, onLayout: (_) async => bytes);
    } else {
      throw UnsupportedError('PDF no disponible');
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible abrir o compartir el PDF. Comprueba las opciones de impresión o descarga de tu plataforma.',
          ),
        ),
      );
    }
  }
}

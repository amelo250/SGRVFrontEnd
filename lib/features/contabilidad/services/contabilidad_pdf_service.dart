import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/contabilidad_resumen.dart';

class ContabilidadPdfService {
  Future<Uint8List> generate(
    ContabilidadResumen data, {
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final pdf = pw.Document(title: 'Reporte contable');
    final money = NumberFormat.currency(locale: 'es_DO', symbol: r'RD$');
    final date = DateFormat('dd/MM/yyyy');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'REPORTE DE CONTABILIDAD',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            desde == null || hasta == null
                ? 'Todos los períodos'
                : '${date.format(desde)} - ${date.format(hasta)}',
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _metric('Ingresos', money.format(data.ingresos)),
              _metric('Gastos', money.format(data.gastos)),
              _metric('Resultado', money.format(data.resultadoNeto)),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Resumen por categoría',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: ['Tipo', 'Categoría', 'Registros', 'Total'],
            data: data.categorias
                .map(
                  (x) => [
                    x.tipo,
                    x.nombre,
                    '${x.cantidad}',
                    money.format(x.total),
                  ],
                )
                .toList(),
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Movimientos',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TableHelper.fromTextArray(
            headers: ['Fecha', 'Tipo', 'Categoría', 'Concepto', 'Monto'],
            data: data.movimientos
                .map(
                  (x) => [
                    date.format(x.fecha),
                    x.tipo,
                    x.categoriaNombre,
                    x.concepto,
                    money.format(x.monto),
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _metric(String label, String value) => pw.Column(
    children: [
      pw.Text(label),
      pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    ],
  );
}

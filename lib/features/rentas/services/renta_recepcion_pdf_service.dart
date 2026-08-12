import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_recepcion_document.dart';

class RentaRecepcionPdfService {
  Future<Uint8List> generate(
    RentaEntrega data,
    RentaRecepcionDocument document,
  ) async {
    final pdf = pw.Document(title: 'Recepción ${data.numeroContrato}');
    final date = DateFormat('dd/MM/yyyy hh:mm a');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (_) => [
          pw.Text(
            data.empresa.nombreComercial,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.Text(
            'DOCUMENTO DE RECEPCIÓN · ${data.numeroContrato}',
            style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
          ),
          pw.Divider(color: PdfColors.blue700),
          _section('CONTRASTE CON LA ENTREGA'),
          _row('Cliente', data.cliente.nombreCompleto),
          _row(
            'Vehículo',
            '${data.vehiculo.marca} ${data.vehiculo.modelo} ${data.vehiculo.anio} · ${data.vehiculo.placa}',
          ),
          _row('Kilometraje de referencia', '${data.vehiculo.kilometraje} km'),
          _row('Retorno previsto', date.format(data.fechaFin)),
          _row('Recepción registrada', date.format(document.fechaRecepcion)),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              _fuelRow('Condición', 'Entrega declarada', 'Recepción'),
              _fuelRow(
                'Combustible',
                '${document.nivelCombustibleEntrega}%',
                '${document.nivelCombustibleRecepcion}%',
              ),
              _fuelRow(
                'Diferencia',
                '',
                '${document.nivelCombustibleRecepcion - document.nivelCombustibleEntrega}%',
              ),
            ],
          ),
          _section('ACCESORIOS RECIBIDOS'),
          pw.Wrap(
            spacing: 12,
            runSpacing: 6,
            children: data.accesorios
                .map(
                  (item) => pw.SizedBox(
                    width: 160,
                    child: pw.Text(
                      '${document.accesoriosRecibidos.contains(item.idAccesorio) ? '[x]' : '[ ]'} ${item.nombre}',
                    ),
                  ),
                )
                .toList(),
          ),
          _section('OBSERVACIONES Y SITUACIONES DE RECEPCIÓN'),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Text(
              document.observaciones?.trim().isNotEmpty == true
                  ? document.observaciones!
                  : 'Sin observaciones.',
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Row(
            children: [
              pw.Expanded(
                child: _signature(
                  document.firmaCliente,
                  data.cliente.nombreCompleto,
                  'Cliente',
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: _signature(
                  document.firmaAgente,
                  document.nombreAgente,
                  'Recibido por',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Nota: los niveles de combustible y las firmas pertenecen a este PDF y no se almacenan en el servidor en la versión actual.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _section(String text) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 16, bottom: 8),
    padding: const pw.EdgeInsets.all(6),
    color: PdfColors.blue50,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
      ),
    ),
  );
  pw.Widget _row(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 5),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.TextSpan(text: value),
        ],
      ),
    ),
  );
  pw.TableRow _fuelRow(String a, String b, String c) => pw.TableRow(
    children: [a, b, c]
        .map(
          (x) => pw.Padding(
            padding: const pw.EdgeInsets.all(7),
            child: pw.Text(x),
          ),
        )
        .toList(),
  );
  pw.Widget _signature(Uint8List bytes, String name, String role) => pw.Column(
    children: [
      pw.SizedBox(
        height: 65,
        child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
      ),
      pw.Divider(),
      pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      pw.Text(role, style: const pw.TextStyle(fontSize: 8)),
    ],
  );
}

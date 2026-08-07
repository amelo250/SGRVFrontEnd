import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega_document.dart';

class RentaEntregaPdfService {
  Future<Uint8List> generate(
    RentaEntrega data,
    RentaEntregaDocument document,
  ) async {
    final pdf = pw.Document(
      title: 'Entrega ${data.numeroContrato}',
      author: data.empresa.nombreComercial,
      subject: 'Constancia de entrega de vehículo',
    );
    final clientSignature = pw.MemoryImage(document.firmaCliente);
    final agentSignature = pw.MemoryImage(document.firmaAgente);
    final date = DateFormat('dd/MM/yyyy');
    final dateTime = DateFormat('dd/MM/yyyy hh:mm a');
    final money = NumberFormat('#,##0.00', 'es_DO');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => _header(data),
        footer: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Generado por SGRV - ${dateTime.format(document.fechaFirma)}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
            pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
            ),
          ],
        ),
        build: (_) => [
          _title('DATOS DEL CLIENTE'),
          _twoColumns([
            _item('Nombre', data.cliente.nombreCompleto),
            _item('Cédula/Pasaporte', data.cliente.cedulaPasaporte),
            _item('Dirección', data.cliente.direccion),
            _item('Teléfono', data.cliente.telefono),
            _item('Nacionalidad', data.cliente.nacionalidad),
            _item('Licencia', data.cliente.licenciaConducir),
            _item(
              'Vence licencia',
              data.cliente.fechaVencimientoLicencia == null
                  ? 'No registrado'
                  : date.format(data.cliente.fechaVencimientoLicencia!),
            ),
          ]),
          _title('DATOS DEL VEHÍCULO'),
          _twoColumns([
            _item(
              'Vehículo',
              '${data.vehiculo.marca} ${data.vehiculo.modelo} ${data.vehiculo.anio}',
            ),
            _item('Tipo', data.vehiculo.tipo),
            _item('Placa', data.vehiculo.placa),
            _item('VIN', data.vehiculo.vin),
            _item('Color', data.vehiculo.color),
            _item('Kilometraje', '${data.vehiculo.kilometraje} km'),
            _item('Salida', dateTime.format(data.fechaInicio)),
            _item('Retorno previsto', dateTime.format(data.fechaFin)),
          ]),
          _title('CONDICIONES ECONÓMICAS'),
          _twoColumns([
            _item(
              'Precio por día',
              '${data.monedaCodigo} ${money.format(data.precioPorDiaPactado)}',
            ),
            _item('Días rentados', '${data.cantidadDias}'),
            _item(
              'Subtotal',
              '${data.monedaCodigo} ${money.format(data.subtotal)}',
            ),
            _item(
              'Impuestos',
              '${data.monedaCodigo} ${money.format(data.impuestos)}',
            ),
            _item(
              'Descuentos',
              '${data.monedaCodigo} ${money.format(data.descuentos)}',
            ),
            _item(
              'Depósito',
              '${data.monedaCodigo} ${money.format(data.deposito)}',
            ),
            _item('Total', '${data.monedaCodigo} ${money.format(data.total)}'),
            _item(
              'Abonos en DOP',
              'DOP ${money.format(data.totalAbonadoLocal)}',
            ),
          ]),
          _title('ACCESORIOS Y EQUIPAMIENTO'),
          pw.Wrap(
            spacing: 12,
            runSpacing: 7,
            children: data.accesorios
                .map(
                  (item) => pw.SizedBox(
                    width: 160,
                    child: pw.Text(
                      '${document.accesoriosConfirmados.contains(item.idAccesorio) ? '[x]' : '[ ]'} ${item.nombre}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          pw.SizedBox(height: 14),
          _title('OBSERVACIONES'),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
            ),
            child: pw.Text(
              _joinNotes(data.observaciones, document.observaciones),
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Text(
            'El cliente declara recibir el vehículo y los elementos marcados en las condiciones descritas. Se compromete a devolverlos y a informar cualquier incidente, daño o pérdida.',
            textAlign: pw.TextAlign.justify,
            style: const pw.TextStyle(fontSize: 9),
          ),
          pw.SizedBox(height: 18),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _signature(
                  clientSignature,
                  data.cliente.nombreCompleto,
                  'Cliente',
                ),
              ),
              pw.SizedBox(width: 24),
              pw.Expanded(
                child: _signature(
                  agentSignature,
                  document.nombreAgente,
                  'Entregado por',
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  pw.Widget _header(RentaEntrega data) => pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    padding: const pw.EdgeInsets.only(bottom: 10),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.blue700, width: 2),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              data.empresa.nombreComercial,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              'RNC ${data.empresa.rnc}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              data.empresa.telefono,
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.Text(
              data.empresa.direccion,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'FORMULARIO DE ENTREGA',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
            ),
            pw.Text('Contrato ${data.numeroContrato}'),
          ],
        ),
      ],
    ),
  );

  pw.Widget _title(String value) => pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(top: 10, bottom: 7),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    color: PdfColors.blue50,
    child: pw.Text(
      value,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blue800,
        fontSize: 10,
      ),
    ),
  );

  pw.Widget _twoColumns(List<pw.Widget> items) => pw.Wrap(
    spacing: 12,
    runSpacing: 5,
    children: items
        .map((item) => pw.SizedBox(width: 245, child: item))
        .toList(growable: false),
  );

  pw.Widget _item(String label, String value) => pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(
        width: 82,
        child: pw.Text(
          '$label:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
        ),
      ),
      pw.Expanded(
        child: pw.Text(
          value.trim().isEmpty ? 'No registrado' : value,
          style: const pw.TextStyle(fontSize: 8.5),
        ),
      ),
    ],
  );

  pw.Widget _signature(pw.ImageProvider image, String name, String role) =>
      pw.Column(
        children: [
          pw.SizedBox(
            height: 65,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
          pw.Divider(color: PdfColors.grey700),
          pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(role, style: const pw.TextStyle(fontSize: 8)),
        ],
      );

  static String _joinNotes(String? first, String? second) {
    final values = [first, second]
        .map((value) => value?.trim())
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return values.isEmpty
        ? 'Sin observaciones adicionales.'
        : values.join('\n');
  }
}

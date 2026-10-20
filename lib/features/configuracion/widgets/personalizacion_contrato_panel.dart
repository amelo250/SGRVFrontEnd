import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/features/empresas/models/empresa.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';

/// Laboratorio temporal: no guarda ni aplica preferencias a contratos firmados.
class PersonalizacionContratoPanel extends StatefulWidget {
  const PersonalizacionContratoPanel({super.key});
  @override
  State<PersonalizacionContratoPanel> createState() =>
      _PersonalizacionContratoPanelState();
}

class _PersonalizacionContratoPanelState
    extends State<PersonalizacionContratoPanel> {
  String _font = 'Helvetica';
  double _size = 11, _title = 20, _spacing = 5;
  bool _bold = false;
  String _align = 'Izquierda';
  final _colors = ['#202020', '#154360', '#FFFFFF', '#EAF2F8', '#9A3412'];
  String _text = '#202020',
      _heading = '#154360',
      _background = '#FFFFFF',
      _header = '#EAF2F8',
      _highlight = '#9A3412';

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Personalización de contratos',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Text(
            'Vista previa temporal. Los ajustes se descartan al salir y no afectan contratos reales. Guardarlos requiere autorizar su persistencia.',
          ),
          _select('Tipografía', _font, [
            'Helvetica',
            'Times',
            'Courier',
          ], (v) => _font = v),
          _select('Alineación', _align, [
            'Izquierda',
            'Centro',
            'Justificada',
          ], (v) => _align = v),
          _slider('Texto', _size, 8, 16, (v) => _size = v),
          _slider('Títulos', _title, 14, 28, (v) => _title = v),
          _slider('Espaciado', _spacing, 0, 12, (v) => _spacing = v),
          SwitchListTile(
            title: const Text('Texto en negrita'),
            value: _bold,
            onChanged: (v) => setState(() => _bold = v),
          ),
          _select('Color del texto', _text, _colors, (v) => _text = v),
          _select('Color de títulos', _heading, _colors, (v) => _heading = v),
          _select('Fondo', _background, _colors, (v) => _background = v),
          _select('Fondo de encabezados', _header, _colors, (v) => _header = v),
          _select(
            'Elementos destacados',
            _highlight,
            _colors,
            (v) => _highlight = v,
          ),
          OutlinedButton.icon(
            onPressed: _preview,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Vista previa de muestra'),
          ),
          const Text(
            'Plantillas propias: PDF como documento fijo; DOCX con campos requiere un motor de plantillas validado. No se habilita carga ni almacenamiento de plantillas en esta versión.',
          ),
        ],
      ),
    ),
  );

  Widget _select(
    String label,
    String value,
    List<String> values,
    void Function(String) update,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) {
        if (v != null) setState(() => update(v));
      },
    ),
  );
  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    void Function(double) update,
  ) => Column(
    children: [
      Text('$label: ${value.round()} pt'),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: (max - min).round(),
        onChanged: (v) => setState(() => update(v)),
      ),
    ],
  );

  Future<void> _preview() async {
    final service = EmpresaService();
    try {
      final company = await service.getCurrent();
      Uint8List? logo;
      if (company.logoUrl?.isNotEmpty == true) {
        final api = ApiClient();
        try {
          logo = Uint8List.fromList(await api.getBytes('${ApiConfig.empresas}/${company.idEmpresa}/logo/contenido'));
        } finally { api.dispose(); }
      }
      final bytes = await generarMuestra(company, logo);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: const Text('Muestra temporal · no es un contrato'),
            ),
            body: PdfPreview(
              build: (_) async => bytes,
              canChangeOrientation: false,
              canChangePageFormat: false,
              allowPrinting: false,
              allowSharing: false,
            ),
          ),
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No fue posible generar la vista previa de la empresa actual.',
            ),
          ),
        );
      }
    } finally {
      service.dispose();
    }
  }

  @visibleForTesting
  Future<Uint8List> generarMuestra(Empresa company, Uint8List? logo) async {
    final pdf = pw.Document();
    final font = switch (_font) {
      'Times' => pw.Font.times(),
      'Courier' => pw.Font.courier(),
      _ => pw.Font.helvetica(),
    };
    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          buildBackground: (_) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(color: PdfColor.fromHex(_background)),
          ),
        ),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (logo != null) pw.Align(alignment: pw.Alignment.centerLeft,
              child: pw.Image(pw.MemoryImage(logo), width: 80, height: 60, fit: pw.BoxFit.contain)),
            pw.Container(
              color: PdfColor.fromHex(_header),
              padding: const pw.EdgeInsets.all(16),
              child: pw.Text(
                company.nombreComercial.isEmpty
                    ? company.nombre
                    : company.nombreComercial,
                style: pw.TextStyle(
                  font: font,
                  fontSize: _title,
                  color: PdfColor.fromHex(_heading),
                ),
              ),
            ),
            pw.SizedBox(height: _spacing + 8),
            pw.Text(
              'RNC ${company.rnc}\n${company.telefono ?? ''}\n${company.correo ?? ''}\n${company.direccion ?? ''}',
              style: pw.TextStyle(
                font: font,
                fontSize: _size,
                color: PdfColor.fromHex(_text),
              ),
            ),
            pw.SizedBox(height: _spacing + 8),
            pw.Text(
              'MUESTRA SIN VALIDEZ CONTRACTUAL',
              style: pw.TextStyle(
                font: font,
                color: PdfColor.fromHex(_highlight),
              ),
            ),
            pw.SizedBox(height: _spacing + 8),
            pw.Text(
              'Contrato de renta de vehículo. Este texto permite revisar la apariencia del documento. Los datos de cliente, vehículo, pagos y firmas se completan únicamente desde la renta registrada.',
              textAlign: switch (_align) {
                'Centro' => pw.TextAlign.center,
                'Justificada' => pw.TextAlign.justify,
                _ => pw.TextAlign.left,
              },
              style: pw.TextStyle(
                font: font,
                fontSize: _size,
                lineSpacing: _spacing,
                fontWeight: _bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: PdfColor.fromHex(_text),
              ),
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }
}

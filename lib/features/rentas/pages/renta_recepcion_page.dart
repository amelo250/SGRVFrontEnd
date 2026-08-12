import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_recepcion_document.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_recepcion_pdf_service.dart';
import 'package:sgrv_frontend/features/rentas/widgets/fuel_level_selector.dart';
import 'package:sgrv_frontend/features/rentas/widgets/signature_pad.dart';

class RentaRecepcionPage extends StatefulWidget {
  const RentaRecepcionPage({required this.rentaId, super.key});
  final int rentaId;

  @override
  State<RentaRecepcionPage> createState() => _RentaRecepcionPageState();
}

class _RentaRecepcionPageState extends State<RentaRecepcionPage> {
  final _agent = TextEditingController();
  final _notes = TextEditingController();
  final _clientSignature = GlobalKey<SignaturePadState>();
  final _agentSignature = GlobalKey<SignaturePadState>();
  final _accessories = <int>{};
  final _pdf = RentaRecepcionPdfService();
  int _deliveryFuel = 100;
  int _receptionFuel = 100;
  bool _working = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RentaProvider>().loadEntrega(widget.rentaId);
      if (!mounted) return;
      final data = context.read<RentaProvider>().entrega;
      if (data != null) {
        setState(
          () => _accessories.addAll(data.accesorios.map((x) => x.idAccesorio)),
        );
      }
    });
  }

  @override
  void dispose() {
    _agent.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentaProvider>();
    final data = provider.entrega;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(title: const Text('Recepción del vehículo')),
      body: provider.loadingEntrega
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? Center(
              child: Text(
                provider.errorMessage ??
                    'No fue posible preparar la recepción.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1050),
                    child: Column(
                      children: [
                        _notice(),
                        _section(
                          'Contraste de combustible',
                          Icons.local_gas_station_outlined,
                          Column(
                            children: [
                              FuelLevelSelector(
                                value: _deliveryFuel,
                                label: 'Nivel indicado en la entrega',
                                onChanged: (x) =>
                                    setState(() => _deliveryFuel = x),
                              ),
                              const SizedBox(height: 18),
                              FuelLevelSelector(
                                value: _receptionFuel,
                                label: 'Nivel al recibir',
                                onChanged: (x) =>
                                    setState(() => _receptionFuel = x),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Diferencia: ${_receptionFuel - _deliveryFuel}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: _receptionFuel < _deliveryFuel
                                      ? Colors.deepOrange
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _section(
                          'Accesorios recibidos',
                          Icons.fact_check_outlined,
                          _accessoryList(data),
                        ),
                        _section(
                          'Observaciones y firmas',
                          Icons.assignment_turned_in_outlined,
                          Column(
                            children: [
                              TextField(
                                controller: _agent,
                                maxLength: 120,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre de quien recibe',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _notes,
                                maxLength: 500,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText:
                                      'Observaciones o situaciones de la recepción',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              LayoutBuilder(
                                builder: (_, c) {
                                  final client = SignaturePad(
                                    key: _clientSignature,
                                    label: 'Firma del cliente',
                                  );
                                  final agent = SignaturePad(
                                    key: _agentSignature,
                                    label: 'Firma de quien recibe',
                                  );
                                  return c.maxWidth >= 720
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: client),
                                            const SizedBox(width: 16),
                                            Expanded(child: agent),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            client,
                                            const SizedBox(height: 16),
                                            agent,
                                          ],
                                        );
                                },
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            spacing: 10,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _working ? null : () => _print(data),
                                icon: const Icon(Icons.print_outlined),
                                label: const Text('Vista previa / imprimir'),
                              ),
                              FilledButton.icon(
                                onPressed: _working ? null : () => _share(data),
                                icon: const Icon(Icons.share_outlined),
                                label: const Text('Compartir PDF'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _notice() => const Card(
    child: ListTile(
      leading: Icon(Icons.info_outline),
      title: Text('Documento de recepción'),
      subtitle: Text(
        'Como el documento de entrega aún no se almacena, indica su nivel de combustible para realizar el contraste. El PDF generado queda bajo control del usuario.',
      ),
    ),
  );
  Widget _section(String title, IconData icon, Widget child) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3867F4)),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );
  Widget _accessoryList(RentaEntrega data) => data.accesorios.isEmpty
      ? const Text('No hay accesorios registrados.')
      : Wrap(
          spacing: 8,
          children: data.accesorios
              .map(
                (x) => FilterChip(
                  selected: _accessories.contains(x.idAccesorio),
                  label: Text(x.nombre),
                  onSelected: (selected) => setState(
                    () => selected
                        ? _accessories.add(x.idAccesorio)
                        : _accessories.remove(x.idAccesorio),
                  ),
                ),
              )
              .toList(),
        );

  Future<Uint8List?> _generate(RentaEntrega data) async {
    if (_agent.text.trim().isEmpty) {
      _message('Indica quién recibe el vehículo.');
      return null;
    }
    setState(() => _working = true);
    try {
      final client = await _clientSignature.currentState?.exportPng();
      final agent = await _agentSignature.currentState?.exportPng();
      if (client == null || agent == null) {
        _message('Se requieren ambas firmas.');
        return null;
      }
      return _pdf.generate(
        data,
        RentaRecepcionDocument(
          nombreAgente: _agent.text.trim(),
          nivelCombustibleEntrega: _deliveryFuel,
          nivelCombustibleRecepcion: _receptionFuel,
          accesoriosRecibidos: Set.unmodifiable(_accessories),
          firmaCliente: client,
          firmaAgente: agent,
          fechaRecepcion: DateTime.now(),
          observaciones: _notes.text.trim(),
        ),
      );
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _print(RentaEntrega data) async {
    final bytes = await _generate(data);
    if (bytes != null) await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  Future<void> _share(RentaEntrega data) async {
    final bytes = await _generate(data);
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'recepcion-${data.numeroContrato}.pdf',
      );
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

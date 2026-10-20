import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_service.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/rentas/services/contrato_pdf_actions.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega_document.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/rentas/services/renta_entrega_pdf_service.dart';
import 'package:sgrv_frontend/features/rentas/widgets/signature_pad.dart';
import 'package:sgrv_frontend/features/rentas/widgets/fuel_level_selector.dart';

class RentaEntregaPage extends StatefulWidget {
  const RentaEntregaPage({required this.rentaId, super.key});

  final int rentaId;

  @override
  State<RentaEntregaPage> createState() => _RentaEntregaPageState();
}

class _RentaEntregaPageState extends State<RentaEntregaPage> {
  final _agentController = TextEditingController();
  final _notesController = TextEditingController();
  final _clientSignatureKey = GlobalKey<SignaturePadState>();
  final _agentSignatureKey = GlobalKey<SignaturePadState>();
  final _selectedAccessories = <int>{};
  final _pdfService = RentaEntregaPdfService();
  bool _working = false;
  int _fuelLevel = 100;
  RentaEntregaDocument? _lastDocument;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RentaProvider>().loadEntrega(widget.rentaId),
    );
  }

  @override
  void dispose() {
    _agentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentaProvider>();
    final data = provider.entrega;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrega del vehículo'),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: provider.loadingEntrega || _working
                ? null
                : () => provider.loadEntrega(widget.rentaId),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: provider.loadingEntrega
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? _error(provider)
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1100),
                    child: Column(
                      children: [
                        _header(context, data),
                        const SizedBox(height: 16),
                        _notice(),
                        if (provider.entregaArchivo != null) ...[
                          const SizedBox(height: 12),
                          _savedDocument(provider),
                        ],
                        const SizedBox(height: 16),
                        _summary(context, data),
                        const SizedBox(height: 16),
                        _fuel(context),
                        const SizedBox(height: 16),
                        _accessories(context, data),
                        Text(
                          'Lugar de entrega: ${data.lugarEntrega ?? 'Por confirmar'}',
                        ),
                        Text(
                          'Lugar de recepción / devolución: ${data.lugarRecepcion ?? 'Por confirmar'}',
                        ),
                        const SizedBox(height: 16),
                        _signatures(context, data),
                        const SizedBox(height: 22),
                        _actions(data),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _fuel(BuildContext context) => _section(
    context,
    title: 'Combustible al entregar',
    icon: Icons.local_gas_station_outlined,
    child: FuelLevelSelector(
      value: _fuelLevel,
      onChanged: (value) => setState(() => _fuelLevel = value),
    ),
  );

  Widget _header(BuildContext context, RentaEntrega data) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outline),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.empresa.nombreComercial,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'RNC ${data.empresa.rnc} · ${data.empresa.telefono}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Chip(
          avatar: const Icon(Icons.description_outlined, size: 18),
          label: Text('Contrato ${data.numeroContrato}'),
        ),
      ],
    ),
  );

  Widget _notice() => const Card(
    child: ListTile(
      leading: Icon(Icons.verified_user_outlined, color: Color(0xFF3867F4)),
      title: Text('Documento generado desde la renta registrada'),
      subtitle: Text(
        'Las firmas se incorporan al PDF. Usa “Guardar formulario” para conservar el documento y sus datos en el servidor de archivos.',
      ),
    ),
  );

  Widget _savedDocument(RentaProvider provider) {
    final saved = provider.entregaArchivo!;
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: const Icon(
          Icons.cloud_done_outlined,
          color: Color(0xFF278455),
        ),
        title: const Text('Formulario firmado guardado'),
        subtitle: Text(
          'Guardado ${DateFormat('dd/MM/yyyy hh:mm a').format(saved.fechaGuardado)} · '
          '${(saved.tamanoBytes / 1024).toStringAsFixed(1)} KB · Combustible ${saved.nivelCombustible}%',
        ),
        trailing: Wrap(children: [
          IconButton(tooltip: 'Abrir PDF guardado', onPressed: _working ? null : () => _openSaved(provider),
            icon: const Icon(Icons.picture_as_pdf_outlined)),
          IconButton(tooltip: 'Compartir o descargar PDF guardado', onPressed: _working ? null : () => _openSaved(provider, compartir: true),
            icon: const Icon(Icons.share_outlined)),
          if (const ['ADMIN', 'SUPADMIN'].contains(context.watch<AuthProvider>().role))
            IconButton(tooltip: 'Copiar enlace seguro de 15 minutos', onPressed: _working ? null : _copyLink,
              icon: const Icon(Icons.link_outlined)),
        ]),
      ),
    );
  }

  Widget _summary(BuildContext context, RentaEntrega data) {
    return _section(
      context,
      title: 'Resumen de la entrega',
      icon: Icons.assignment_outlined,
      child: Wrap(
        spacing: 28,
        runSpacing: 16,
        children: [
          _value('Cliente', data.cliente.nombreCompleto),
          _value(
            'Vehículo',
            '${data.vehiculo.marca} ${data.vehiculo.modelo} ${data.vehiculo.anio}',
          ),
          _value('Placa', data.vehiculo.placa),
          _value('Color', data.vehiculo.color),
          _value(
            'Salida',
            PeriodoAlquilerFechas.formato(
              data.fechaInicio,
              data.periodoSinHora,
            ),
          ),
          _value(
            'Retorno',
            PeriodoAlquilerFechas.formato(data.fechaFin, data.periodoSinHora),
          ),
          _value(
            'Precio diario',
            '${data.monedaCodigo} ${data.precioPorDiaPactado.toStringAsFixed(2)}',
          ),
          _value(
            'Total',
            '${data.monedaCodigo} ${data.total.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _accessories(BuildContext context, RentaEntrega data) => _section(
    context,
    title: 'Accesorios entregados',
    icon: Icons.checklist_rounded,
    child: data.accesorios.isEmpty
        ? const Text('El vehículo no tiene accesorios activos registrados.')
        : Wrap(
            spacing: 10,
            runSpacing: 8,
            children: data.accesorios
                .map(
                  (item) => FilterChip(
                    selected: _selectedAccessories.contains(item.idAccesorio),
                    label: Text(item.nombre),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedAccessories.add(item.idAccesorio);
                      } else {
                        _selectedAccessories.remove(item.idAccesorio);
                      }
                    }),
                  ),
                )
                .toList(growable: false),
          ),
  );

  Widget _signatures(BuildContext context, RentaEntrega data) => _section(
    context,
    title: 'Conformidad y firmas',
    icon: Icons.draw_outlined,
    child: Column(
      children: [
        TextFormField(
          controller: _agentController,
          maxLength: 120,
          decoration: const InputDecoration(
            labelText: 'Nombre de quien entrega',
            prefixIcon: Icon(Icons.badge_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLength: 500,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Observaciones de entrega',
            prefixIcon: Icon(Icons.notes_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final client = SignaturePad(
              key: _clientSignatureKey,
              label: 'Firma del cliente - ${data.cliente.nombreCompleto}',
            );
            final agent = SignaturePad(
              key: _agentSignatureKey,
              label: 'Firma de quien entrega',
            );
            return constraints.maxWidth >= 760
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: client),
                      const SizedBox(width: 16),
                      Expanded(child: agent),
                    ],
                  )
                : Column(children: [client, const SizedBox(height: 16), agent]);
          },
        ),
      ],
    ),
  );

  Widget _actions(RentaEntrega data) => Align(
    alignment: Alignment.centerRight,
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        FilledButton.icon(
          onPressed: _working ? null : () => _save(data),
          icon: const Icon(Icons.cloud_upload_outlined),
          label: const Text('Guardar formulario'),
        ),
        OutlinedButton.icon(
          onPressed: _working ? null : () => _print(data),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Vista previa / imprimir'),
        ),
        FilledButton.icon(
          onPressed: _working ? null : () => _share(data),
          icon: _working
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.share_outlined),
          label: const Text('Compartir PDF'),
        ),
      ],
    ),
  );

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3867F4)),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );

  Widget _value(String label, String value) => SizedBox(
    width: 225,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.trim().isEmpty ? 'No registrado' : value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );

  Widget _error(RentaProvider provider) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 52),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'No fue posible cargar la entrega.'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => provider.loadEntrega(widget.rentaId),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );

  Future<RentaEntregaDocument?> _captureDocument() async {
    final agent = _agentController.text.trim();
    if (agent.isEmpty) {
      _message('Indica el nombre de quien entrega el vehículo.');
      return null;
    }
    final clientSignature = await _clientSignatureKey.currentState?.exportPng();
    final agentSignature = await _agentSignatureKey.currentState?.exportPng();
    if (clientSignature == null || agentSignature == null) {
      _message('Se requieren la firma del cliente y de quien entrega.');
      return null;
    }
    return RentaEntregaDocument(
      nombreAgente: agent,
      accesoriosConfirmados: Set.unmodifiable(_selectedAccessories),
      firmaCliente: clientSignature,
      firmaAgente: agentSignature,
      fechaFirma: DateTime.now(),
      nivelCombustible: _fuelLevel,
      observaciones: _notesController.text.trim(),
    );
  }

  Future<Uint8List?> _generate(RentaEntrega data) async {
    setState(() => _working = true);
    try {
      final document = await _captureDocument();
      if (document == null) return null;
      _lastDocument = document;
      return await _pdfService.generate(data, document);
    } catch (error) {
      _message(
        error is ApiException
            ? error.message
            : 'No fue posible generar el PDF.',
      );
      return null;
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _print(RentaEntrega data) async {
    final bytes = await _generate(data);
    if (bytes == null) return;
    if (!mounted) return;
    await presentarContratoPdf(context, bytes, filename: 'entrega-${data.numeroContrato}.pdf');
  }

  Future<void> _share(RentaEntrega data) async {
    final bytes = await _generate(data);
    if (bytes == null) return;
    if (!mounted) return;
    await presentarContratoPdf(context, bytes, filename: 'entrega-${data.numeroContrato}.pdf', compartir: true);
  }

  Future<void> _save(RentaEntrega data) async {
    final bytes = await _generate(data);
    final document = _lastDocument;
    if (bytes == null || document == null || !mounted) return;
    setState(() => _working = true);
    final provider = context.read<RentaProvider>();
    final saved = await provider.saveEntregaDocument(
      id: data.idRenta,
      bytes: bytes,
      nombreAgente: document.nombreAgente,
      nivelCombustible: document.nivelCombustible,
      fechaFirma: document.fechaFirma,
      accesoriosConfirmados: document.accesoriosConfirmados,
      observaciones: document.observaciones,
    );
    if (mounted) setState(() => _working = false);
    if (!mounted) return;
    _message(
      saved
          ? 'Formulario de entrega guardado correctamente.'
          : provider.errorMessage ?? 'No fue posible guardar el formulario.',
    );
  }

  Future<void> _openSaved(RentaProvider provider, {bool compartir = false}) async {
    setState(() => _working = true);
    final bytes = await provider.getEntregaDocumentBytes(widget.rentaId);
    if (mounted) setState(() => _working = false);
    if (!mounted) return;
    if (bytes == null) {
      _message(provider.errorMessage ?? 'No fue posible recuperar el contrato guardado.');
      return;
    }
    await presentarContratoPdf(context, Uint8List.fromList(bytes),
      filename: 'entrega-R-${widget.rentaId}.pdf', compartir: compartir);
  }

  Future<void> _copyLink() async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: const Text('Compartir enlace temporal'),
      content: const Text('Cualquier persona con el enlace podrá consultar el PDF guardado durante 15 minutos. Compártelo únicamente con el destinatario autorizado.'),
      actions: [TextButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Crear y copiar'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _working = true);
    final service = RentaService();
    try {
      final url = await service.crearEnlaceContrato(widget.rentaId);
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) _message('Enlace copiado. Caduca en 15 minutos.');
    } catch (e) {
      if (mounted) _message(e is ApiException ? e.message : 'No fue posible crear o copiar el enlace.');
    } finally { service.dispose(); if (mounted) setState(() => _working = false); }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}

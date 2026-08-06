import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../models/cliente.dart';
import '../models/documento_cliente.dart';
import '../providers/documento_cliente_provider.dart';
import '../widgets/documento_cliente_card.dart';

class ClienteDocumentosPage extends StatefulWidget {
  const ClienteDocumentosPage({required this.cliente, super.key});
  final Cliente cliente;

  @override
  State<ClienteDocumentosPage> createState() => _ClienteDocumentosPageState();
}

class _ClienteDocumentosPageState extends State<ClienteDocumentosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<DocumentoClienteProvider>().load(
        widget.cliente.idCliente,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DocumentoClienteProvider>();
    return AppModuleScaffold(
      title: 'Documentos del cliente',
      subtitle:
          '${widget.cliente.nombreCompleto} · '
          '${widget.cliente.cedulaPasaporte}',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: provider.mutating ? null : () => _upload(provider),
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Agregar documento'),
      ),
      body: Column(
        children: [
          AppSectionCard(
            title: 'Identidad y licencias',
            subtitle:
                'Las imágenes se almacenan de forma privada y requieren una sesión válida.',
            icon: Icons.badge_outlined,
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: Color(0xFF3867F4)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${provider.documentos.length} documentos registrados',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: () => provider.load(widget.cliente.idCliente),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: _body(provider)),
        ],
      ),
    );
  }

  Widget _body(DocumentoClienteProvider provider) {
    if (provider.loading)
      return const Center(child: CircularProgressIndicator());
    if (provider.error != null) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudieron cargar los documentos',
        message: provider.error,
        onRetry: () => provider.load(widget.cliente.idCliente),
      );
    }
    if (provider.documentos.isEmpty) {
      return const AppStateView(
        icon: Icons.badge_outlined,
        title: 'No hay documentos registrados',
        message: 'Carga la cédula, pasaporte o licencia del cliente.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.load(widget.cliente.idCliente),
      child: LayoutBuilder(
        builder: (context, constraints) => GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 90),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth >= 950
                ? 3
                : constraints.maxWidth >= 580
                ? 2
                : 1,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.22,
          ),
          itemCount: provider.documentos.length,
          itemBuilder: (_, index) {
            final documento = provider.documentos[index];
            return DocumentoClienteCard(
              documento: documento,
              imageHeaders: provider.imageHeaders,
              onView: () => _view(documento, provider.imageHeaders),
              onDelete: () => _delete(provider, documento),
            );
          },
        ),
      ),
    );
  }

  Future<void> _upload(DocumentoClienteProvider provider) async {
    if (provider.tipos.isEmpty) {
      _message(
        'No existen tipos activos cuya categoría contenga DOCUMENT. '
        'Configura primero el catálogo correspondiente.',
      );
      return;
    }
    final idTipo = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _TypeDialog(types: provider.tipos),
    );
    if (idTipo == null || !mounted) return;
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 2400,
    );
    if (file == null || !mounted) return;
    final extension = file.name.toLowerCase();
    final contentType = extension.endsWith('.png')
        ? 'image/png'
        : extension.endsWith('.webp')
        ? 'image/webp'
        : 'image/jpeg';
    final success = await provider.upload(
      idCliente: widget.cliente.idCliente,
      idTipoDocumento: idTipo,
      bytes: await file.readAsBytes(),
      fileName: file.name,
      contentType: contentType,
    );
    if (!success && mounted)
      _message(provider.error ?? 'No fue posible cargar.');
  }

  void _view(DocumentoCliente documento, Map<String, String>? headers) {
    final url = documento.urlDocumento.startsWith('http')
        ? documento.urlDocumento
        : '${ApiConfig.baseUrl}${documento.urlDocumento}';
    showDialog<void>(
      context: context,
      builder: (_) => Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            title: Text(documento.tipoDocumentoNombre),
            leading: const CloseButton(),
          ),
          body: InteractiveViewer(
            minScale: .5,
            maxScale: 5,
            child: Center(
              child: Image.network(url, headers: headers, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _delete(
    DocumentoClienteProvider provider,
    DocumentoCliente documento,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Eliminar documento'),
        content: Text(
          '¿Deseas eliminar ${documento.tipoDocumentoNombre}? '
          'El esquema actual no permite restaurarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await provider.delete(
      widget.cliente.idCliente,
      documento.idDocumentoCliente,
    );
    if (!success && mounted)
      _message(provider.error ?? 'No fue posible eliminar.');
  }

  void _message(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _TypeDialog extends StatefulWidget {
  const _TypeDialog({required this.types});
  final List<TipoDocumentoCliente> types;

  @override
  State<_TypeDialog> createState() => _TypeDialogState();
}

class _TypeDialogState extends State<_TypeDialog> {
  int? selected;

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.badge_outlined),
    title: const Text('Tipo de documento'),
    content: DropdownButtonFormField<int>(
      initialValue: selected,
      decoration: const InputDecoration(labelText: 'Documento'),
      items: widget.types
          .map(
            (item) =>
                DropdownMenuItem(value: item.id, child: Text(item.nombre)),
          )
          .toList(),
      onChanged: (value) => setState(() => selected = value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: selected == null
            ? null
            : () => Navigator.pop(context, selected),
        child: const Text('Continuar'),
      ),
    ],
  );
}

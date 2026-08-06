import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import '../models/documento_cliente.dart';

class DocumentoClienteCard extends StatelessWidget {
  const DocumentoClienteCard({
    required this.documento,
    required this.onView,
    required this.onDelete,
    this.imageHeaders,
    super.key,
  });

  final DocumentoCliente documento;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: InkWell(
            onTap: documento.esImagen ? onView : null,
            child: SizedBox.expand(
              child: documento.esImagen
                  ? Image.network(
                      _url,
                      headers: imageHeaders,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _DocumentFallback(),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                    )
                  : const _DocumentFallback(pdf: true),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      documento.tipoDocumentoNombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      _formatDate(documento.fechaSubida),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Eliminar documento',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  String get _url => documento.urlDocumento.startsWith('http')
      ? documento.urlDocumento
      : '${ApiConfig.baseUrl}${documento.urlDocumento}';

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _DocumentFallback extends StatelessWidget {
  const _DocumentFallback({this.pdf = false});
  final bool pdf;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Center(
      child: Icon(
        pdf ? Icons.picture_as_pdf_rounded : Icons.broken_image_outlined,
        size: 58,
      ),
    ),
  );
}

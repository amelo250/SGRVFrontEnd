import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/clientes/models/cliente.dart';

class ClienteCard extends StatelessWidget {
  const ClienteCard({
    required this.cliente,
    required this.onEditar,
    required this.onDesactivar,
    required this.onRestaurar,
    super.key,
  });

  final Cliente cliente;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;
  final VoidCallback onRestaurar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: cliente.activo ? onEditar : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  _initials(cliente),
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nombreCompleto,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(cliente.cedulaPasaporte),
                    if (cliente.telefono != null ||
                        cliente.email != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        [cliente.telefono, cliente.email]
                            .whereType<String>()
                            .join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Chip(
                avatar: Icon(
                  cliente.activo ? Icons.check_circle : Icons.block,
                  size: 18,
                ),
                label: Text(cliente.activo ? 'Activo' : 'Inactivo'),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'editar') onEditar();
                  if (value == 'desactivar') onDesactivar();
                  if (value == 'restaurar') onRestaurar();
                },
                itemBuilder: (_) => [
                  if (cliente.activo)
                    const PopupMenuItem(
                      value: 'editar',
                      child: Text('Editar'),
                    ),
                  PopupMenuItem(
                    value: cliente.activo ? 'desactivar' : 'restaurar',
                    child: Text(
                      cliente.activo ? 'Desactivar' : 'Restaurar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(Cliente cliente) {
    final first = cliente.nombre.trim();
    final last = cliente.apellido.trim();
    return '${first.isEmpty ? '' : first[0]}'
            '${last.isEmpty ? '' : last[0]}'
        .toUpperCase();
  }
}

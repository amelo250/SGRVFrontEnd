import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';

class VehiculoCard extends StatelessWidget {
  const VehiculoCard({
    required this.vehiculo,
    required this.onAdministrar,
    required this.onEditar,
    required this.onDesactivar,
    this.imageHeaders,
    super.key,
  });

  final Vehiculo vehiculo;
  final VoidCallback onAdministrar;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;
  final Map<String, String>? imageHeaders;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdministrar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _cover(colors),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 12,
                    child: Chip(
                      avatar: Icon(
                        vehiculo.activo
                            ? Icons.check_circle_rounded
                            : Icons.block_rounded,
                        size: 17,
                      ),
                      label: Text(vehiculo.activo ? 'Activo' : 'Inactivo'),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: PopupMenuButton<String>(
                      color: colors.surface,
                      onSelected: (value) {
                        if (value == 'administrar') {
                          onAdministrar();
                        } else if (value == 'editar') {
                          onEditar();
                        } else {
                          onDesactivar();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'administrar',
                          child: ListTile(
                            leading: Icon(Icons.dashboard_customize_outlined),
                            title: Text('Administrar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'editar',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded),
                            title: Text('Editar'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'desactivar',
                          child: ListTile(
                            leading: Icon(Icons.visibility_off_outlined),
                            title: Text('Desactivar'),
                          ),
                        ),
                      ],
                      icon: const CircleAvatar(
                        backgroundColor: Color(0xCCFFFFFF),
                        child: Icon(Icons.more_vert_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${vehiculo.marca} ${vehiculo.modelo}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${vehiculo.placa} · ${vehiculo.anio} · '
                    '${vehiculo.tipoPropiedad.label}',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 7,
                    children: [
                      _feature(
                        Icons.category_outlined,
                        vehiculo.tipoNombre ?? 'Tipo no indicado',
                      ),
                      _feature(
                        Icons.local_gas_station_outlined,
                        vehiculo.combustibleNombre ?? 'Combustible no indicado',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'RD\$ ${vehiculo.precioPorDia.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Text(
                        '/ día',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cover(ColorScheme colors) {
    final relativeUrl = vehiculo.fotoPortadaUrl;
    if (relativeUrl == null || relativeUrl.trim().isEmpty) {
      return ColoredBox(
        color: colors.primaryContainer,
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 72,
          color: colors.onPrimaryContainer,
        ),
      );
    }
    final url = relativeUrl.startsWith('http')
        ? relativeUrl
        : '${ApiConfig.baseUrl}$relativeUrl';
    return Image.network(
      url,
      headers: imageHeaders,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: const Icon(Icons.broken_image_outlined, size: 54),
      ),
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : ColoredBox(
              color: colors.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }

  Widget _feature(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3FA),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 16), const SizedBox(width: 5), Text(label)],
    ),
  );
}

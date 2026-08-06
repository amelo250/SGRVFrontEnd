import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';

class VehiculoCard extends StatelessWidget {
  const VehiculoCard({
    required this.vehiculo,
    required this.onAdministrar,
    required this.onEditar,
    required this.onDesactivar,
    super.key,
  });

  final Vehiculo vehiculo;
  final VoidCallback onAdministrar;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onAdministrar,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${vehiculo.marca} ${vehiculo.modelo}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehiculo.placa} · ${vehiculo.anio} · '
                      '${vehiculo.tipoPropiedad.label}',
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'RD\$ ${vehiculo.precioPorDia.toStringAsFixed(2)} / día',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(vehiculo.activo ? 'Activo' : 'Inactivo'),
                avatar: Icon(
                  vehiculo.activo ? Icons.check_circle : Icons.block,
                  size: 18,
                ),
              ),
              PopupMenuButton<String>(
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
                    child: Text('Administrar'),
                  ),
                  PopupMenuItem(value: 'editar', child: Text('Editar')),
                  PopupMenuItem(value: 'desactivar', child: Text('Desactivar')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

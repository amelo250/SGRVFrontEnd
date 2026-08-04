import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';

class ReservacionCard extends StatelessWidget {
  const ReservacionCard({
    required this.reservacion,
    required this.onEdit,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final Reservacion reservacion;
  final VoidCallback onEdit;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('dd/MM/yyyy HH:mm');
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: reservacion.puedeEditar ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 27,
                child: Text('#${reservacion.idReservacion}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservacion.clienteNombre,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(reservacion.vehiculoDescripcion),
                    const SizedBox(height: 5),
                    Text(
                      '${format.format(reservacion.fechaInicio)} — '
                      '${format.format(reservacion.fechaFin)}',
                    ),
                  ],
                ),
              ),
              Chip(label: Text(reservacion.estadoNombre)),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'confirm') onConfirm();
                  if (value == 'cancel') onCancel();
                },
                itemBuilder: (_) => [
                  if (reservacion.puedeEditar)
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  if (reservacion.puedeConfirmar)
                    const PopupMenuItem(
                      value: 'confirm',
                      child: Text('Confirmar'),
                    ),
                  if (reservacion.puedeCancelar)
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Text('Cancelar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

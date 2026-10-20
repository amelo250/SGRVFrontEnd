import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:flutter/material.dart';
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
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: reservacion.puedeEditar ? onEdit : null,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                child: Text('#${reservacion.idReservacion}'),
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservacion.clienteNombre,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(reservacion.vehiculoDescripcion),
                  Text(
                    'Entrega: ${reservacion.lugarEntrega ?? 'Por confirmar'}',
                  ),
                  Text(
                    'Recepción: ${reservacion.lugarRecepcion ?? 'Por confirmar'}',
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${PeriodoAlquilerFechas.formato(reservacion.fechaInicio, reservacion.periodoSinHora)} — '
                    '${PeriodoAlquilerFechas.formato(reservacion.fechaFin, reservacion.periodoSinHora)}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(label: Text(reservacion.estadoNombre)),
                  if (reservacion.puedeEditar ||
                      reservacion.puedeConfirmar ||
                      reservacion.puedeCancelar)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'confirm') onConfirm();
                        if (value == 'cancel') onCancel();
                      },
                      itemBuilder: (_) => [
                        if (reservacion.puedeEditar)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Editar'),
                          ),
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
            ],
          ),
        ),
      ),
    );
  }
}

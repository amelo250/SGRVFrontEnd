import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/calendario/models/calendario_evento.dart';

class CalendarioEventoCard extends StatelessWidget {
  const CalendarioEventoCard({required this.evento, super.key});

  final CalendarioEvento evento;

  @override
  Widget build(BuildContext context) {
    final color = evento.esReservacion ? Colors.orange : Colors.blue;
    final hour = DateFormat('h:mm a');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          evento.vehiculo,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      Chip(label: Text(evento.estado)),
                    ],
                  ),
                  Text(evento.cliente),
                  const SizedBox(height: 5),
                  Text(
                    '${hour.format(evento.fechaInicio)} – '
                    '${hour.format(evento.fechaFin)} · '
                    '${evento.esReservacion ? 'Reservación' : 'Renta'}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_status_chip.dart';

class RentaCard extends StatelessWidget {
  const RentaCard({required this.renta, required this.onOpen, super.key});

  final Renta renta;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy');
    final money = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '${renta.monedaSimbolo} ',
    );
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.key_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Renta #${renta.idRenta}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  RentaStatusChip(
                    code: renta.estadoCodigo,
                    label: renta.estadoNombre,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                renta.clienteNombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                renta.vehiculoDescripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 17),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      '${(renta.periodoSinHora ? PeriodoAlquilerFechas.formato(renta.fechaInicio, true) : date.format(renta.fechaInicio))} – '
                      '${(renta.periodoSinHora ? PeriodoAlquilerFechas.formato(renta.fechaFin, true) : date.format(renta.fechaFin))}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${renta.cantidadDias} día${renta.cantidadDias == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    money.format(renta.total),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
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
}

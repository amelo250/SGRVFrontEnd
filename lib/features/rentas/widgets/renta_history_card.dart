import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/rentas/models/renta.dart';
import 'package:sgrv_frontend/features/rentas/widgets/renta_status_chip.dart';

class RentaHistoryCard extends StatelessWidget {
  const RentaHistoryCard({
    required this.renta,
    required this.onOpen,
    super.key,
  });

  final Renta renta;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy');
    final money = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '${renta.monedaSimbolo} ',
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Renta #${renta.idRenta}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  RentaStatusChip(
                    code: renta.estadoCodigo,
                    label: renta.estadoNombre,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                renta.clienteNombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 3),
              Text(
                renta.vehiculoDescripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.event_available_outlined, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      date.format(renta.fechaEntregaReal ?? renta.fechaFin),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    money.format(renta.total),
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right_rounded, size: 19),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

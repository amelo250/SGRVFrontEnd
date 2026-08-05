import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/pagos/models/pago.dart';
import 'package:sgrv_frontend/features/pagos/widgets/pago_status_chip.dart';

class PagoCard extends StatelessWidget {
  const PagoCard({required this.pago, required this.onTap, super.key});

  final Pago pago;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'es_DO',
      symbol:
          '${pago.simboloMoneda.isEmpty ? pago.codigoMoneda : pago.simboloMoneda} ',
    );
    final date = DateFormat('dd MMM yyyy · hh:mm a', 'es_DO');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.payments_rounded,
                  color: Color(0xFF3867F4),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pago.clienteNombre.isEmpty
                          ? 'Renta #${pago.idRenta}'
                          : pago.clienteNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pago.metodoPagoNombre} · ${pago.vehiculoDescripcion}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF727C91)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.format(pago.fechaPago),
                      style: const TextStyle(
                        color: Color(0xFF8A93A7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    money.format(pago.monto),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 7),
                  PagoStatusChip(
                    code: pago.estadoCodigo,
                    label: pago.estadoNombre,
                    active: pago.activo,
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

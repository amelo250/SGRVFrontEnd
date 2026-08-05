import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_summary.dart';

class RentaFinancialSummary extends StatelessWidget {
  const RentaFinancialSummary({required this.summary, super.key});

  final RentaSummary summary;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen financiero',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 18),
            _row(
              'Total en moneda local',
              money.format(summary.totalMonedaLocal),
            ),
            _row('Total pagado', money.format(summary.totalPagadoMonedaLocal)),
            const Divider(height: 26),
            _row(
              'Balance pendiente',
              money.format(summary.balancePendienteMonedaLocal),
              emphasized: true,
              color: summary.balancePendienteMonedaLocal > 0
                  ? const Color(0xFFE07A1F)
                  : const Color(0xFF16855B),
            ),
            if (summary.montoSobrepagoMonedaLocal > 0)
              _row(
                'Sobrepago',
                money.format(summary.montoSobrepagoMonedaLocal),
                color: const Color(0xFF315BD5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool emphasized = false,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasized ? 18 : 15,
            fontWeight: emphasized ? FontWeight.w900 : FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

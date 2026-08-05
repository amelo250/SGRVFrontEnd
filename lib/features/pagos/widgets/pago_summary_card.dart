import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/features/pagos/models/pago_summary.dart';

class PagoSummaryCard extends StatelessWidget {
  const PagoSummaryCard({required this.summary, super.key});

  final PagoSummary summary;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$ ');
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF173C9B), Color(0xFF5E55D8)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen de la renta',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _row('Total', money.format(summary.totalRentaMonedaLocal)),
          _row('Pagado', money.format(summary.totalPagadoMonedaLocal)),
          const Divider(color: Colors.white24),
          _row(
            'Pendiente',
            money.format(summary.balancePendienteMonedaLocal),
            strong: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool strong = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            fontSize: strong ? 18 : 14,
          ),
        ),
      ],
    ),
  );
}

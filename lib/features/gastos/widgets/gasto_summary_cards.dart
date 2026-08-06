import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto_summary.dart';

class GastoSummaryCards extends StatelessWidget {
  const GastoSummaryCards({required this.summary, super.key});
  final GastoSummary? summary;
  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_DO', symbol: r'RD$');
    final data = summary;
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        _Card(
          label: 'Gasto total',
          value: money.format(data?.total ?? 0),
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFF3867F4),
        ),
        _Card(
          label: 'Mantenimiento',
          value: money.format(data?.mantenimiento ?? 0),
          icon: Icons.car_repair_rounded,
          color: const Color(0xFFFFA52F),
        ),
        _Card(
          label: 'Operativos',
          value: money.format(data?.operativo ?? 0),
          icon: Icons.business_center_rounded,
          color: const Color(0xFF7057F5),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

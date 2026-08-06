import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vehiculo_resumen_financiero.dart';

class VehiculoFinancialSummary extends StatelessWidget {
  const VehiculoFinancialSummary({required this.summary, super.key});

  final VehiculoResumenFinanciero summary;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(locale: 'es_DO', symbol: r'RD$');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            _MetricCard(
              label: 'Ingresos cobrados',
              value: money.format(summary.ingresosMonedaLocal),
              icon: Icons.trending_up_rounded,
              color: const Color(0xFF2EBE7E),
            ),
            _MetricCard(
              label: 'Gastos registrados',
              value: money.format(summary.gastosMonedaLocal),
              icon: Icons.trending_down_rounded,
              color: const Color(0xFFE94B4B),
            ),
            _MetricCard(
              label: 'Resultado neto',
              value: money.format(summary.resultadoNeto),
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF3867F4),
            ),
            _MetricCard(
              label: 'Rentas realizadas',
              value: '${summary.cantidadRentas}',
              icon: Icons.key_rounded,
              color: const Color(0xFF7057F5),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 40,
              runSpacing: 18,
              children: [
                _Detail(
                  label: 'Ingreso promedio por renta',
                  value: money.format(summary.ingresoPromedioPorRenta),
                ),
                _Detail(
                  label: 'Última renta',
                  value: _date(summary.ultimaRenta),
                ),
                _Detail(
                  label: 'Último gasto',
                  value: _date(summary.ultimoGasto),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _date(DateTime? value) => value == null
      ? 'Sin registros'
      : DateFormat('dd MMM yyyy', 'es_DO').format(value);
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
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
    width: 245,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
                  const SizedBox(height: 5),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
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

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 220,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

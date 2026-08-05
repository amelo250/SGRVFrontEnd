import 'package:flutter/material.dart';

class PagoStatusChip extends StatelessWidget {
  const PagoStatusChip({
    required this.code,
    required this.label,
    required this.active,
    super.key,
  });

  final String code;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF168A5B) : const Color(0xFFC44747);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        active ? (label.isEmpty ? code : label) : 'Anulado',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

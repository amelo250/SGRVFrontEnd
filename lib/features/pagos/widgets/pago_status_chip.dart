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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = active
        ? (dark ? const Color(0xFF83DBB0) : const Color(0xFF126F4B))
        : (dark ? const Color(0xFFFFB4AB) : const Color(0xFFAF3030));
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
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

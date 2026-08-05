import 'package:flutter/material.dart';

class RentaStatusChip extends StatelessWidget {
  const RentaStatusChip({required this.code, required this.label, super.key});

  final String code;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(code, Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  static (Color, Color) _colors(String value, ColorScheme scheme) =>
      switch (value.toUpperCase()) {
        'ACTIVA' => (const Color(0xFFE4F8EF), const Color(0xFF16855B)),
        'FINALIZADA' => (const Color(0xFFE9EFFF), const Color(0xFF315BD5)),
        'CANCELADA' => (const Color(0xFFFFE9E8), const Color(0xFFB73535)),
        _ => (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      };
}

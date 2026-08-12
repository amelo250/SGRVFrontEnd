import 'package:flutter/material.dart';

class FuelLevelSelector extends StatelessWidget {
  const FuelLevelSelector({
    required this.value,
    required this.onChanged,
    this.label = 'Nivel registrado',
    super.key,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final String label;

  static const levels = [0, 25, 50, 75, 100];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(Icons.local_gas_station_rounded, color: Color(0xFF3867F4)),
          const SizedBox(width: 8),
          Text(
            '$label: $value%',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
      const SizedBox(height: 10),
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value / 100,
          minHeight: 18,
          backgroundColor: const Color(0xFFE5E9F2),
          color: value <= 25 ? Colors.orange : const Color(0xFF33A46C),
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: levels
            .map(
              (level) => ChoiceChip(
                selected: value == level,
                label: Text(
                  level == 0
                      ? 'Vacío'
                      : level == 100
                      ? 'Lleno'
                      : '$level%',
                ),
                onSelected: (_) => onChanged(level),
              ),
            )
            .toList(growable: false),
      ),
    ],
  );
}

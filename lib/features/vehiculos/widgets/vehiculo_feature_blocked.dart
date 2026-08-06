import 'package:flutter/material.dart';

class VehiculoFeatureBlocked extends StatelessWidget {
  const VehiculoFeatureBlocked({
    required this.title,
    required this.message,
    required this.icon,
    this.examples = const [],
    super.key,
  });

  final String title;
  final String message;
  final IconData icon;
  final List<String> examples;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 680),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFF3867F4).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(icon, size: 34, color: const Color(0xFF3867F4)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7B8498)),
              ),
              if (examples.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: examples
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

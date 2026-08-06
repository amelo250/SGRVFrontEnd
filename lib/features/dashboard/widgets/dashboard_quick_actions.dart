import 'package:flutter/material.dart';

class DashboardQuickAction {
  const DashboardQuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({required this.actions, super.key});

  final List<DashboardQuickAction> actions;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF3867F4).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.bolt_rounded, color: Color(0xFF3867F4)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pasos rápidos',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Inicia las operaciones más frecuentes sin salir del Dashboard.',
                      style: TextStyle(color: Color(0xFF7B8498)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1100
                  ? 6
                  : constraints.maxWidth >= 650
                  ? 3
                  : 2;
              const gap = 12.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: actions
                    .map(
                      (action) => SizedBox(
                        width: width,
                        child: _QuickActionTile(action: action),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({required this.action});

  final DashboardQuickAction action;

  @override
  Widget build(BuildContext context) => Material(
    color: action.color.withValues(alpha: .065),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        action.color,
                        action.color.withValues(alpha: .72),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(action.icon, color: Colors.white, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: action.color,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              action.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              action.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF7B8498), fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/dashboard/widgets/dashboard_quick_actions.dart';

class DashboardQuickActionsFab extends StatefulWidget {
  const DashboardQuickActionsFab({required this.actions, super.key});

  final List<DashboardQuickAction> actions;

  @override
  State<DashboardQuickActionsFab> createState() =>
      _DashboardQuickActionsFabState();
}

class _DashboardQuickActionsFabState extends State<DashboardQuickActionsFab> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 240,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      verticalDirection: VerticalDirection.up,
      children: [
        FloatingActionButton.extended(
          heroTag: 'dashboard-quick-actions',
          tooltip: _expanded ? 'Cerrar pasos rápidos' : 'Abrir pasos rápidos',
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: AnimatedRotation(
            turns: _expanded ? .125 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(_expanded ? Icons.close_rounded : Icons.bolt_rounded),
          ),
          label: Text(_expanded ? 'Cerrar' : 'Paso rápido'),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          reverseDuration: const Duration(milliseconds: 160),
          layoutBuilder: (currentChild, previousChildren) => Stack(
            alignment: Alignment.bottomRight,
            children: [...previousChildren, ?currentChild],
          ),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(
              sizeFactor: animation,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
          child: _expanded
              ? Padding(
                  key: const ValueKey('quick-actions'),
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: widget.actions.reversed
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: FloatingActionButton.extended(
                              heroTag: 'quick-${action.title}',
                              backgroundColor: Colors.white,
                              foregroundColor: action.color,
                              elevation: 4,
                              onPressed: () {
                                setState(() => _expanded = false);
                                action.onTap();
                              },
                              icon: Icon(action.icon),
                              label: Text(
                                action.title,
                                style: const TextStyle(
                                  color: Color(0xFF172033),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('quick-actions-closed')),
        ),
      ],
    ),
  );
}

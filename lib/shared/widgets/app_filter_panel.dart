import 'package:flutter/material.dart';

/// Keeps controls mounted so collapsing never clears search text or selections.
class AppFilterPanel extends StatefulWidget {
  const AppFilterPanel({required this.child, super.key});

  final Widget child;

  @override
  State<AppFilterPanel> createState() => _AppFilterPanelState();
}

class _AppFilterPanelState extends State<AppFilterPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          expanded: _expanded,
          child: OutlinedButton.icon(
            onPressed: () {
              if (_expanded) FocusScope.of(context).unfocus();
              setState(() => _expanded = !_expanded);
            },
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filtros'),
                const SizedBox(width: 8),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
      Offstage(
        offstage: !_expanded,
        child: ExcludeFocus(
          excluding: !_expanded,
          child: TickerMode(
            enabled: _expanded,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight:
                      (MediaQuery.sizeOf(context).height -
                          MediaQuery.viewInsetsOf(context).bottom) *
                      .38,
                ),
                child: SingleChildScrollView(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RentaDateFilterBar extends StatelessWidget {
  const RentaDateFilterBar({
    required this.from,
    required this.to,
    required this.onChanged,
    super.key,
  });

  final DateTime? from;
  final DateTime? to;
  final Future<void> Function(DateTime? from, DateTime? to) onChanged;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy');
    final label = from == null || to == null
        ? 'Todas las fechas'
        : '${formatter.format(from!)} – ${formatter.format(to!)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ActionChip(
            avatar: const Icon(Icons.date_range_outlined, size: 18),
            label: Text(label),
            onPressed: () => _custom(context),
          ),
          _preset(context, 'Este mes', _month(DateTime.now())),
          _preset(context, 'Mes pasado', _previousMonth()),
          _preset(context, 'Este año', _year(DateTime.now().year)),
          PopupMenuButton<int>(
            tooltip: 'Seleccionar año',
            itemBuilder: (_) => List.generate(6, (index) {
              final year = DateTime.now().year - index;
              return PopupMenuItem(value: year, child: Text('$year'));
            }),
            onSelected: (year) {
              final range = _year(year);
              onChanged(range.start, range.end);
            },
            child: const Chip(
              avatar: Icon(Icons.calendar_view_month_outlined, size: 18),
              label: Text('Año'),
            ),
          ),
          if (from != null || to != null)
            IconButton(
              tooltip: 'Limpiar fechas',
              onPressed: () => onChanged(null, null),
              icon: const Icon(Icons.filter_alt_off_outlined),
            ),
        ],
      ),
    );
  }

  Widget _preset(BuildContext context, String label, DateTimeRange range) =>
      ActionChip(
        label: Text(label),
        onPressed: () => onChanged(range.start, range.end),
      );

  Future<void> _custom(BuildContext context) async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 2, 12, 31),
      initialDateRange: from != null && to != null
          ? DateTimeRange(start: from!, end: to!)
          : null,
      helpText: 'Filtrar rentas por período',
    );
    if (result != null) {
      await onChanged(
        result.start,
        DateTime(
          result.end.year,
          result.end.month,
          result.end.day,
          23,
          59,
          59,
          999,
        ),
      );
    }
  }

  static DateTimeRange _month(DateTime date) => DateTimeRange(
    start: DateTime(date.year, date.month),
    end: DateTime(
      date.year,
      date.month + 1,
    ).subtract(const Duration(milliseconds: 1)),
  );

  static DateTimeRange _previousMonth() =>
      _month(DateTime(DateTime.now().year, DateTime.now().month - 1));

  static DateTimeRange _year(int year) => DateTimeRange(
    start: DateTime(year),
    end: DateTime(year + 1).subtract(const Duration(milliseconds: 1)),
  );
}

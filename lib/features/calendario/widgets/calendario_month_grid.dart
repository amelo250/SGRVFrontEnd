import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/calendario/models/calendario_evento.dart';

class CalendarioMonthGrid extends StatelessWidget {
  const CalendarioMonthGrid({
    required this.month,
    required this.selectedDay,
    required this.eventsForDay,
    required this.onSelected,
    super.key,
  });

  final DateTime month;
  final DateTime selectedDay;
  final List<CalendarioEvento> Function(DateTime) eventsForDay;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - DateTime.monday;
    final days = DateTime(month.year, month.month + 1, 0).day;
    final cells = ((leading + days + 6) ~/ 7) * 7;
    const labels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Column(
      children: [
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.2,
          children: labels
              .map(
                (label) => Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              )
              .toList(),
        ),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.05,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells,
          itemBuilder: (context, index) {
            final dayNumber = index - leading + 1;
            if (dayNumber < 1 || dayNumber > days) return const SizedBox();
            final day = DateTime(month.year, month.month, dayNumber);
            final events = eventsForDay(day);
            final selected = _sameDay(day, selectedDay);
            final today = _sameDay(day, DateTime.now());
            return Padding(
              padding: const EdgeInsets.all(3),
              child: Material(
                color: selected
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: today
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor.withValues(alpha: .45),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelected(day),
                  child: Padding(
                    padding: const EdgeInsets.all(7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            fontWeight: selected || today
                                ? FontWeight.w900
                                : FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (events.isNotEmpty)
                          Wrap(
                            spacing: 3,
                            children: events
                                .take(3)
                                .map(
                                  (event) => Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: event.esReservacion
                                          ? Colors.orange
                                          : Colors.blue,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

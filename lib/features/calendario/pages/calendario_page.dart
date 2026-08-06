import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/calendario/providers/calendario_provider.dart';
import 'package:sgrv_frontend/features/calendario/widgets/calendario_evento_card.dart';
import 'package:sgrv_frontend/features/calendario/widgets/calendario_month_grid.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

class CalendarioPage extends StatefulWidget {
  const CalendarioPage({super.key});

  @override
  State<CalendarioPage> createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<CalendarioProvider>().cargar(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalendarioProvider>();
    return AppModuleScaffold(
      title: 'Calendario',
      subtitle: 'Reservaciones y rentas organizadas en una sola vista.',
      actions: [
        IconButton(
          tooltip: 'Actualizar',
          onPressed: () => provider.cargar(refresh: true),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      body: _body(provider),
    );
  }

  Widget _body(CalendarioProvider provider) {
    if (provider.status == CalendarioStatus.initial ||
        provider.status == CalendarioStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.status == CalendarioStatus.error) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No pudimos cargar el calendario',
        message: provider.errorMessage,
        onRetry: provider.cargar,
      );
    }

    final selectedEvents = provider.eventosDelDia(provider.diaSeleccionado);
    return RefreshIndicator(
      onRefresh: () => provider.cargar(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _Toolbar(provider: provider),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              final calendar = Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CalendarioMonthGrid(
                    month: provider.mesVisible,
                    selectedDay: provider.diaSeleccionado,
                    eventsForDay: provider.eventosDelDia,
                    onSelected: provider.seleccionarDia,
                  ),
                ),
              );
              final detail = _DayPanel(
                provider: provider,
                eventCount: selectedEvents.length,
              );
              return wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: calendar),
                        const SizedBox(width: 16),
                        Expanded(flex: 2, child: detail),
                      ],
                    )
                  : Column(
                      children: [calendar, const SizedBox(height: 16), detail],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.provider});

  final CalendarioProvider provider;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton.filledTonal(
            onPressed: () => provider.cambiarMes(-1),
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          SizedBox(
            width: 180,
            child: Text(
              DateFormat('MMMM yyyy', 'es').format(provider.mesVisible),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => provider.cambiarMes(1),
            icon: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(width: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'TODOS', label: Text('Todos')),
              ButtonSegment(
                value: 'RESERVACION',
                label: Text('Reservaciones'),
              ),
              ButtonSegment(value: 'RENTA', label: Text('Rentas')),
            ],
            selected: {provider.tipo ?? 'TODOS'},
            onSelectionChanged: (value) => provider.filtrarTipo(
              value.first == 'TODOS' ? null : value.first,
            ),
          ),
        ],
      ),
    ),
  );
}

class _DayPanel extends StatelessWidget {
  const _DayPanel({required this.provider, required this.eventCount});

  final CalendarioProvider provider;
  final int eventCount;

  @override
  Widget build(BuildContext context) {
    final events = provider.eventosDelDia(provider.diaSeleccionado);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                "EEEE, d 'de' MMMM",
                'es',
              ).format(provider.diaSeleccionado),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text('$eventCount eventos'),
            const SizedBox(height: 16),
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('No hay actividad para este día.')),
              )
            else
              ...events.map((event) => CalendarioEventoCard(evento: event)),
          ],
        ),
      ),
    );
  }
}

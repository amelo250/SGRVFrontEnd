import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/dashboard/models/dashboard_task.dart';
import 'package:sgrv_frontend/features/dashboard/providers/dashboard_task_provider.dart';

class DashboardTasksSection extends StatelessWidget {
  const DashboardTasksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardTaskProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3867F4).withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    color: Color(0xFF3867F4),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tareas operativas',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Entregas, recepciones y mantenimientos más cercanos.',
                        style: TextStyle(color: Color(0xFF7B8498)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Actualizar tareas',
                  onPressed: () => provider.load(refresh: true),
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (provider.status == DashboardTaskStatus.loading ||
                provider.status == DashboardTaskStatus.initial)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.status == DashboardTaskStatus.error)
              _StateMessage(
                icon: Icons.cloud_off_rounded,
                message: provider.error ?? 'No fue posible cargar las tareas.',
                onRetry: provider.load,
              )
            else if (provider.status == DashboardTaskStatus.empty)
              const _StateMessage(
                icon: Icons.event_available_rounded,
                message: 'No hay tareas para hoy ni para los próximos días.',
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 780;
                  final today = _TaskGroup(
                    title: 'Hoy',
                    count: provider.data!.totalHoy,
                    tasks: provider.data!.hoy,
                    accent: const Color(0xFF3867F4),
                  );
                  final upcoming = _TaskGroup(
                    title: 'Próximas',
                    count: provider.data!.totalProximas,
                    tasks: provider.data!.proximas,
                    accent: const Color(0xFF7057F5),
                  );
                  return wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: today),
                            const SizedBox(width: 18),
                            Expanded(child: upcoming),
                          ],
                        )
                      : Column(
                          children: [
                            today,
                            const SizedBox(height: 18),
                            upcoming,
                          ],
                        );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskGroup extends StatelessWidget {
  const _TaskGroup({
    required this.title,
    required this.count,
    required this.tasks,
    required this.accent,
  });
  final String title;
  final int count;
  final List<DashboardTask> tasks;
  final Color accent;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 8),
          Badge(
            backgroundColor: accent,
            label: Text('$count'),
          ),
        ],
      ),
      const SizedBox(height: 10),
      if (tasks.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 22),
          child: Center(child: Text('Sin tareas')),
        )
      else
        ...tasks.map((task) => _TaskTile(task: task, accent: accent)),
    ],
  );
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.accent});
  final DashboardTask task;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (task.tipo) {
      'ENTREGA' => (Icons.key_rounded, Colors.green),
      'RECEPCION' => (Icons.assignment_return_rounded, Colors.blue),
      'MANTENIMIENTO' => (Icons.build_circle_rounded, Colors.orange),
      _ => (Icons.task_alt_rounded, accent),
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .065),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: .12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.titulo, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(
                  task.vehiculo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF7B8498)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            task.esHoy
                ? DateFormat('h:mm a').format(task.fecha)
                : DateFormat('dd MMM\nh:mm a').format(task.fecha),
            textAlign: TextAlign.right,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.icon, required this.message, this.onRetry});
  final IconData icon;
  final String message;
  final Future<void> Function()? onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(icon, size: 38, color: const Color(0xFF7B8498)),
          const SizedBox(height: 9),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
        ],
      ),
    ),
  );
}

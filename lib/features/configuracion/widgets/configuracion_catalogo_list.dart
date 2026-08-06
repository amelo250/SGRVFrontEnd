import 'package:flutter/material.dart';
import '../models/configuracion_catalogo.dart';

class ConfiguracionCatalogoList extends StatelessWidget {
  const ConfiguracionCatalogoList({
    required this.items,
    required this.onEdit,
    required this.onToggle,
    super.key,
  });

  final List<ConfiguracionCatalogoItem> items;
  final ValueChanged<ConfiguracionCatalogoItem> onEdit;
  final ValueChanged<ConfiguracionCatalogoItem> onToggle;

  @override
  Widget build(BuildContext context) => ListView.separated(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.only(bottom: 90),
    itemCount: items.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final item = items[index];
      return Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: item.activo
                ? const Color(0xFFE9EEFF)
                : const Color(0xFFF0F1F4),
            child: Icon(
              item.activo ? Icons.tune_rounded : Icons.block_rounded,
              color: item.activo ? const Color(0xFF3867F4) : Colors.grey,
            ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  item.nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (item.esGlobal) ...[
                const SizedBox(width: 8),
                const Chip(label: Text('Global')),
              ],
            ],
          ),
          subtitle: Text(
            [
              item.codigo,
              if (item.categoria != null) item.categoria!,
              if (item.simbolo != null) item.simbolo!,
              if (item.descripcion != null) item.descripcion!,
            ].join(' · '),
          ),
          trailing: item.esGlobal && item.rowVersion != null
              ? const Tooltip(
                  message: 'Los accesorios globales son de solo lectura.',
                  child: Icon(Icons.lock_outline_rounded),
                )
              : PopupMenuButton<String>(
                  onSelected: (value) =>
                      value == 'edit' ? onEdit(item) : onToggle(item),
                  itemBuilder: (_) => [
                    if (item.activo)
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_rounded),
                          title: Text('Editar'),
                        ),
                      ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          item.activo
                              ? Icons.visibility_off_rounded
                              : Icons.restore_rounded,
                        ),
                        title: Text(item.activo ? 'Desactivar' : 'Restaurar'),
                      ),
                    ),
                  ],
                ),
        ),
      );
    },
  );
}

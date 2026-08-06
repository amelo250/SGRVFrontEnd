import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../models/gasto.dart';
import '../providers/gasto_provider.dart';
import 'gasto_form_page.dart';

class GastoDetailPage extends StatelessWidget {
  const GastoDetailPage({required this.gasto, super.key});
  final Gasto gasto;
  @override
  Widget build(BuildContext context) => AppModuleScaffold(
    title: gasto.concepto,
    subtitle:
        '${gasto.tipoNombre} · ${DateFormat('dd MMMM yyyy', 'es_DO').format(gasto.fecha)}',
    actions: [
      IconButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GastoFormPage(gasto: gasto)),
          );
          if (context.mounted) Navigator.pop(context);
        },
        icon: const Icon(Icons.edit_rounded),
      ),
    ],
    body: ListView(
      children: [
        AppSectionCard(
          title: 'Detalle financiero',
          child: Wrap(
            spacing: 30,
            runSpacing: 20,
            children: [
              _item(
                'Monto',
                '${gasto.monedaSimbolo} ${NumberFormat('#,##0.00').format(gasto.monto)}',
              ),
              _item(
                'Tasa aplicada',
                gasto.tasaCambioAplicada.toStringAsFixed(6),
              ),
              _item(
                'Monto local',
                NumberFormat.currency(
                  locale: 'es_DO',
                  symbol: r'RD$',
                ).format(gasto.montoMonedaLocal),
              ),
              _item('Proveedor', gasto.proveedor ?? 'No indicado'),
              _item('Comprobante', gasto.numeroComprobante ?? 'No indicado'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppSectionCard(
          title: 'Asignación',
          child: Wrap(
            spacing: 30,
            runSpacing: 20,
            children: [
              _item(
                'Vehículo',
                gasto.vehiculoDescripcion ?? 'Gasto operativo general',
              ),
              _item(
                'Kilometraje',
                gasto.kilometraje?.toString() ?? 'No indicado',
              ),
              _item('Taller', gasto.taller ?? 'No indicado'),
              _item(
                'Observaciones',
                gasto.observaciones ?? 'Sin observaciones',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await context.read<GastoProvider>().delete(
                gasto.idGasto,
              );
              if (context.mounted && ok) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar'),
          ),
        ),
      ],
    ),
  );

  Widget _item(String label, String value) => SizedBox(
    width: 240,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}

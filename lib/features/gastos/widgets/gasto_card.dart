import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gasto.dart';

class GastoCard extends StatelessWidget {
  const GastoCard({required this.gasto, required this.onTap, super.key});
  final Gasto gasto;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      leading: CircleAvatar(
        child: Icon(
          gasto.idVehiculo == null
              ? Icons.receipt_long_rounded
              : Icons.car_repair_rounded,
        ),
      ),
      title: Text(
        gasto.concepto,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
      subtitle: Text(
        '${gasto.tipoNombre} · ${DateFormat('dd MMM yyyy', 'es_DO').format(gasto.fecha)}${gasto.vehiculoDescripcion == null ? '' : ' · ${gasto.vehiculoDescripcion}'}',
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${gasto.monedaSimbolo} ${NumberFormat('#,##0.00').format(gasto.monto)}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            gasto.activo ? 'Activo' : 'Eliminado',
            style: TextStyle(color: gasto.activo ? Colors.green : Colors.red),
          ),
        ],
      ),
    ),
  );
}

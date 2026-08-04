import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/proveedores/models/proveedor_vehiculo.dart';

class ProveedorVehiculoCard extends StatelessWidget {
  const ProveedorVehiculoCard({
    required this.proveedor,
    required this.onEditar,
    required this.onDesactivar,
    super.key,
  });

  final ProveedorVehiculo proveedor;
  final VoidCallback onEditar;
  final VoidCallback onDesactivar;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            proveedor.nombre.isEmpty ? '?' : proveedor.nombre[0].toUpperCase(),
          ),
        ),
        title: Text(proveedor.nombre),
        subtitle: Text(
          [
            'RNC/Cédula: ${proveedor.rncCedula}',
            if (proveedor.contacto?.isNotEmpty == true) proveedor.contacto!,
            if (proveedor.telefono?.isNotEmpty == true) proveedor.telefono!,
          ].join(' · '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(label: Text(proveedor.activo ? 'Activo' : 'Inactivo')),
            IconButton(
              tooltip: 'Editar',
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined),
            ),
            if (proveedor.activo)
              IconButton(
                tooltip: 'Desactivar',
                onPressed: onDesactivar,
                icon: const Icon(Icons.person_off_outlined),
              ),
          ],
        ),
      ),
    );
  }
}

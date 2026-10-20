import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import 'package:sgrv_frontend/features/mantenimientos/services/mantenimiento_service.dart';

/// Carga versión actual y conserva esa versión durante la confirmación.
/// La API valida el permiso y la pertenencia empresarial antes del cierre.
Future<bool> completarMantenimientoDialog(BuildContext context, int id) async {
  final service = MantenimientoService();
  try {
    final estado = await service.getEstado(id);
    if (!context.mounted) return false;
    if (estado.completado) return true;
    if (!estado.pendiente || estado.rowVersion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El mantenimiento está sin clasificar o no admite completado.',
          ),
        ),
      );
      return false;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Completar mantenimiento'),
        content: const Text(
          'Se guardarán la fecha de completado y el usuario responsable. El registro quedará cerrado para edición.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;
    await service.completar(id, estado.rowVersion);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mantenimiento completado.')),
      );
    }
    return true;
  } on ApiException catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
    return false;
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No fue posible completar el mantenimiento. Actualiza e inténtalo otra vez.',
          ),
        ),
      );
    }
    return false;
  } finally {
    service.dispose();
  }
}

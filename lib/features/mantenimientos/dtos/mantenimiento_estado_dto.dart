import 'package:sgrv_frontend/features/mantenimientos/models/mantenimiento.dart';

/// Datos operativos de la API, separados del modelo de mantenimiento existente.
class MantenimientoEstadoDto {
  const MantenimientoEstadoDto({
    required this.id,
    required this.estado,
    required this.rowVersion,
    this.fechaCompletadoUtc,
    this.idUsuarioCompletado,
    this.nombreUsuarioCompletado,
  });

  final int id;
  final String estado;
  final String rowVersion;
  final DateTime? fechaCompletadoUtc;
  final int? idUsuarioCompletado;
  final String? nombreUsuarioCompletado;
  String get usuarioCompletadoEtiqueta =>
      nombreUsuarioCompletado?.trim().isNotEmpty == true
      ? nombreUsuarioCompletado!.trim()
      : "Usuario no disponible";
  bool get pendiente => estado == 'PENDIENTE';
  bool get completado => estado == 'COMPLETADO';
  String get etiqueta => switch (estado) {
    'PENDIENTE' => 'Pendiente',
    'COMPLETADO' => 'Completado',
    _ => 'Sin clasificar',
  };

  factory MantenimientoEstadoDto.fromJson(Map<String, dynamic> json) =>
      MantenimientoEstadoDto(
        id: (json['idMantenimiento'] as num).toInt(),
        estado: json['estado']?.toString() ?? 'SIN_CLASIFICAR',
        rowVersion: json['rowVersion']?.toString() ?? '',
        fechaCompletadoUtc: DateTime.tryParse(
          json['fechaCompletadoUtc']?.toString() ?? '',
        ),
        idUsuarioCompletado: (json['idUsuarioCompletado'] as num?)?.toInt(),
        nombreUsuarioCompletado: json['nombreUsuarioCompletado']?.toString(),
      );
}

class MantenimientoListadoDto {
  const MantenimientoListadoDto(this.mantenimiento, this.operacion);
  final Mantenimiento mantenimiento;
  final MantenimientoEstadoDto operacion;

  factory MantenimientoListadoDto.fromJson(Map<String, dynamic> json) =>
      MantenimientoListadoDto(
        Mantenimiento.fromJson(json),
        MantenimientoEstadoDto.fromJson(json),
      );
}

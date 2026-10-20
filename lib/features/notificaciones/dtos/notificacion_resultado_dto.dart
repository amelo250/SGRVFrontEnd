class NotificacionResultadoDto {
  const NotificacionResultadoDto({
    required this.destinatario,
    required this.canal,
    required this.estado,
    required this.mensaje,
  });
  final String destinatario;
  final String canal;
  final String estado;
  final String mensaje;
  factory NotificacionResultadoDto.fromJson(Map<String, dynamic> json) =>
      NotificacionResultadoDto(
        destinatario: json['destinatario'] as String,
        canal: json['canal'] as String,
        estado: json['estado'] as String,
        mensaje: json['mensaje'] as String,
      );
  String get estadoDescripcion => switch (estado) {
    'SIMULADO' => 'Listo para enviar',
    'ACEPTADO' => 'Aceptado por el proveedor',
    'NO_CONFIGURADO' => 'Canal sin configurar',
    'CONTACTO_INVALIDO' => 'Contacto inválido',
    'YA_PROCESADO' => 'Existe un intento previo',
    'INCIERTO' => 'Resultado incierto',
    _ => 'Requiere revisión',
  };
}

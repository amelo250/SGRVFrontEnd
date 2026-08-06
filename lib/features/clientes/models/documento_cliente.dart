class DocumentoCliente {
  const DocumentoCliente({
    required this.idDocumentoCliente,
    required this.idCliente,
    required this.idTipoDocumento,
    required this.tipoDocumentoNombre,
    required this.urlDocumento,
    required this.fechaSubida,
    this.tipoContenido,
  });

  final int idDocumentoCliente;
  final int idCliente;
  final int idTipoDocumento;
  final String tipoDocumentoNombre;
  final String urlDocumento;
  final DateTime fechaSubida;
  final String? tipoContenido;

  bool get esImagen => tipoContenido?.startsWith('image/') ?? true;

  factory DocumentoCliente.fromJson(Map<String, dynamic> json) {
    return DocumentoCliente(
      idDocumentoCliente: (json['idDocumentoCliente'] as num).toInt(),
      idCliente: (json['idCliente'] as num).toInt(),
      idTipoDocumento: (json['idTipoDocumento'] as num).toInt(),
      tipoDocumentoNombre: json['tipoDocumentoNombre']?.toString() ?? '',
      urlDocumento: json['urlDocumento']?.toString() ?? '',
      fechaSubida:
          DateTime.tryParse(json['fechaSubida']?.toString() ?? '') ??
          DateTime(1900),
      tipoContenido: json['tipoContenido']?.toString(),
    );
  }
}

class TipoDocumentoCliente {
  const TipoDocumentoCliente({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  final int id;
  final String codigo;
  final String nombre;

  factory TipoDocumentoCliente.fromJson(Map<String, dynamic> json) =>
      TipoDocumentoCliente(
        id: (json['id'] as num).toInt(),
        codigo: json['codigo']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
      );
}

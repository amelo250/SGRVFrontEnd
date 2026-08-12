import 'dart:typed_data';

class RentaEntregaDocument {
  const RentaEntregaDocument({
    required this.nombreAgente,
    required this.accesoriosConfirmados,
    required this.firmaCliente,
    required this.firmaAgente,
    required this.fechaFirma,
    required this.nivelCombustible,
    this.observaciones,
  });

  final String nombreAgente;
  final Set<int> accesoriosConfirmados;
  final Uint8List firmaCliente;
  final Uint8List firmaAgente;
  final DateTime fechaFirma;
  final int nivelCombustible;
  final String? observaciones;
}

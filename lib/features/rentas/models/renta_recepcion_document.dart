import 'dart:typed_data';

class RentaRecepcionDocument {
  const RentaRecepcionDocument({
    required this.nombreAgente,
    required this.nivelCombustibleEntrega,
    required this.nivelCombustibleRecepcion,
    required this.accesoriosRecibidos,
    required this.firmaCliente,
    required this.firmaAgente,
    required this.fechaRecepcion,
    this.observaciones,
  });

  final String nombreAgente;
  final int nivelCombustibleEntrega;
  final int nivelCombustibleRecepcion;
  final Set<int> accesoriosRecibidos;
  final Uint8List firmaCliente;
  final Uint8List firmaAgente;
  final DateTime fechaRecepcion;
  final String? observaciones;
}

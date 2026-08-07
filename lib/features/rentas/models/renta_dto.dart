class RentaCreateDto {
  const RentaCreateDto({
    required this.idCliente,
    required this.idVehiculo,
    required this.fechaInicio,
    required this.fechaFin,
    this.precioPorDiaPactado,
    required this.impuestos,
    required this.descuentos,
    required this.deposito,
    required this.tasaCambioAplicada,
    this.observaciones,
  });

  final int idCliente;
  final int idVehiculo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double? precioPorDiaPactado;
  final double impuestos;
  final double descuentos;
  final double deposito;
  final double tasaCambioAplicada;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'idCliente': idCliente,
    'idVehiculo': idVehiculo,
    'fechaInicio': fechaInicio.toUtc().toIso8601String(),
    'fechaFin': fechaFin.toUtc().toIso8601String(),
    'precioPorDiaPactado': precioPorDiaPactado,
    'impuestos': impuestos,
    'descuentos': descuentos,
    'deposito': deposito,
    'tasaCambioAplicada': tasaCambioAplicada,
    'observaciones': nullableText(observaciones),
  };
}

class RentaUpdateDto extends RentaCreateDto {
  const RentaUpdateDto({
    required super.idCliente,
    required super.idVehiculo,
    required super.fechaInicio,
    required super.fechaFin,
    super.precioPorDiaPactado,
    required super.impuestos,
    required super.descuentos,
    required super.deposito,
    required super.tasaCambioAplicada,
    required this.rowVersion,
    super.observaciones,
  });

  final String rowVersion;

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'rowVersion': rowVersion,
  };
}

class ConvertirReservacionRentaDto {
  const ConvertirReservacionRentaDto({
    this.precioPorDiaPactado,
    required this.impuestos,
    required this.descuentos,
    required this.deposito,
    required this.tasaCambioAplicada,
    this.observaciones,
  });

  final double? precioPorDiaPactado;

  final double impuestos;
  final double descuentos;
  final double deposito;
  final double tasaCambioAplicada;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'precioPorDiaPactado': precioPorDiaPactado,
    'impuestos': impuestos,
    'descuentos': descuentos,
    'deposito': deposito,
    'tasaCambioAplicada': tasaCambioAplicada,
    'observaciones': nullableText(observaciones),
  };
}

class FinalizarRentaDto {
  const FinalizarRentaDto({
    required this.fechaEntregaReal,
    required this.rowVersion,
    this.observaciones,
  });

  final DateTime fechaEntregaReal;
  final String rowVersion;
  final String? observaciones;

  Map<String, dynamic> toJson() => {
    'fechaEntregaReal': fechaEntregaReal.toUtc().toIso8601String(),
    'rowVersion': rowVersion,
    'observaciones': nullableText(observaciones),
  };
}

String? nullableText(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

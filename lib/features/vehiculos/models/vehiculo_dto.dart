import 'package:sgrv_frontend/features/vehiculos/models/vehiculo.dart';

class VehiculoDto {
  const VehiculoDto({
    required this.idCombustible,
    required this.idTransmision,
    required this.idTipo,
    required this.tipoPropiedad,
    required this.idMonedaTarifa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.precioPorDia,
    required this.kilometraje,
    required this.depositoCombustible,
    this.idProveedorVehiculo,
    this.color,
    this.vin,
    this.descripcion,
  });

  final int idCombustible;
  final int idTransmision;
  final int idTipo;
  final TipoPropiedadVehiculo tipoPropiedad;
  final int? idProveedorVehiculo;
  final int idMonedaTarifa;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String? color;
  final String? vin;
  final double precioPorDia;
  final int kilometraje;
  final String? descripcion;
  final double depositoCombustible;

  Map<String, dynamic> toJson() => {
    'idCombustible': idCombustible,
    'idTransmision': idTransmision,
    'idTipo': idTipo,
    'tipoPropiedad': tipoPropiedad.value,
    'idProveedorVehiculo': idProveedorVehiculo,
    'idMonedaTarifa': idMonedaTarifa,
    'marca': marca,
    'modelo': modelo,
    'anio': anio,
    'placa': placa,
    'color': color,
    'vin': vin,
    'precioPorDia': precioPorDia,
    'kilometraje': kilometraje,
    'descripcion': descripcion,
    'depositoCombustible': depositoCombustible,
  };
}

class VehiculoEstadoUpdateDto {
  const VehiculoEstadoUpdateDto(this.idEstado);
  final int idEstado;
  Map<String, dynamic> toJson() => {'idEstado': idEstado};
}

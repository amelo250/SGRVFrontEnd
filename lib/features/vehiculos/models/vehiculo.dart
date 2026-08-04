enum TipoPropiedadVehiculo {
  propio(1, 'Propio'),
  tercero(2, 'Tercero');

  const TipoPropiedadVehiculo(this.value, this.label);
  final int value;
  final String label;

  static TipoPropiedadVehiculo fromValue(int value) {
    return values.firstWhere((item) => item.value == value);
  }
}

class Vehiculo {
  const Vehiculo({
    required this.idVehiculo,
    required this.idEstado,
    required this.idCombustible,
    required this.idTransmision,
    required this.idTipo,
    required this.tipoPropiedad,
    required this.idMonedaTarifa,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.kilometraje,
    required this.precioPorDia,
    required this.depositoCombustible,
    required this.activo,
    required this.fechaCreacion,
    this.idProveedorVehiculo,
    this.vin,
    this.color,
    this.descripcion,
  });

  final int idVehiculo;
  final int idEstado;
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
  final String? vin;
  final String? color;
  final int kilometraje;
  final double precioPorDia;
  final double depositoCombustible;
  final String? descripcion;
  final bool activo;
  final DateTime fechaCreacion;

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      idVehiculo: (json['idVehiculo'] as num).toInt(),
      idEstado: (json['idEstado'] as num).toInt(),
      idCombustible: (json['idCombustible'] as num).toInt(),
      idTransmision: (json['idTransmision'] as num).toInt(),
      idTipo: (json['idTipo'] as num).toInt(),
      tipoPropiedad: TipoPropiedadVehiculo.fromValue(
        (json['tipoPropiedad'] as num).toInt(),
      ),
      idProveedorVehiculo: (json['idProveedorVehiculo'] as num?)?.toInt(),
      idMonedaTarifa: (json['idMonedaTarifa'] as num).toInt(),
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      anio: (json['anio'] as num).toInt(),
      placa: json['placa']?.toString() ?? '',
      vin: json['vin']?.toString(),
      color: json['color']?.toString(),
      kilometraje: (json['kilometraje'] as num).toInt(),
      precioPorDia: (json['precioPorDia'] as num).toDouble(),
      depositoCombustible: (json['depositoCombustible'] as num).toDouble(),
      descripcion: json['descripcion']?.toString(),
      activo: json['activo'] as bool? ?? false,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
    );
  }
}

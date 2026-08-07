class RentaEntrega {
  const RentaEntrega({
    required this.idRenta,
    required this.idVehiculo,
    required this.numeroContrato,
    required this.empresa,
    required this.cliente,
    required this.vehiculo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioPorDiaPactado,
    required this.cantidadDias,
    required this.subtotal,
    required this.impuestos,
    required this.descuentos,
    required this.deposito,
    required this.total,
    required this.monedaCodigo,
    required this.monedaSimbolo,
    required this.pagos,
    required this.accesorios,
    this.observaciones,
  });

  final int idRenta;
  final int idVehiculo;
  final String numeroContrato;
  final RentaEntregaEmpresa empresa;
  final RentaEntregaCliente cliente;
  final RentaEntregaVehiculo vehiculo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double precioPorDiaPactado;
  final int cantidadDias;
  final double subtotal;
  final double impuestos;
  final double descuentos;
  final double deposito;
  final double total;
  final String monedaCodigo;
  final String monedaSimbolo;
  final String? observaciones;
  final List<RentaEntregaPago> pagos;
  final List<RentaEntregaAccesorio> accesorios;

  double get totalAbonadoLocal =>
      pagos.fold(0, (total, payment) => total + payment.montoMonedaLocal);

  factory RentaEntrega.fromJson(Map<String, dynamic> json) => RentaEntrega(
    idRenta: _int(json['idRenta']),
    idVehiculo: _int(json['idVehiculo']),
    numeroContrato: _text(json['numeroContrato']),
    empresa: RentaEntregaEmpresa.fromJson(_map(json['empresa'])),
    cliente: RentaEntregaCliente.fromJson(_map(json['cliente'])),
    vehiculo: RentaEntregaVehiculo.fromJson(_map(json['vehiculo'])),
    fechaInicio: _date(json['fechaInicio']),
    fechaFin: _date(json['fechaFin']),
    precioPorDiaPactado: _double(json['precioPorDiaPactado']),
    cantidadDias: _int(json['cantidadDias']),
    subtotal: _double(json['subtotal']),
    impuestos: _double(json['impuestos']),
    descuentos: _double(json['descuentos']),
    deposito: _double(json['deposito']),
    total: _double(json['total']),
    monedaCodigo: _text(json['monedaCodigo']),
    monedaSimbolo: _text(json['monedaSimbolo']),
    observaciones: _nullableText(json['observaciones']),
    pagos: _list(json['pagos'])
        .map((item) => RentaEntregaPago.fromJson(_map(item)))
        .toList(growable: false),
    accesorios: _list(json['accesorios'])
        .map((item) => RentaEntregaAccesorio.fromJson(_map(item)))
        .toList(growable: false),
  );
}

class RentaEntregaEmpresa {
  const RentaEntregaEmpresa({
    required this.nombreComercial,
    required this.rnc,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.logoUrl,
  });

  final String nombreComercial;
  final String rnc;
  final String telefono;
  final String email;
  final String direccion;
  final String? logoUrl;

  factory RentaEntregaEmpresa.fromJson(Map<String, dynamic> json) =>
      RentaEntregaEmpresa(
        nombreComercial: _text(json['nombreComercial']),
        rnc: _text(json['rnc']),
        telefono: _text(json['telefono']),
        email: _text(json['email']),
        direccion: _text(json['direccion']),
        logoUrl: _nullableText(json['logoUrl']),
      );
}

class RentaEntregaCliente {
  const RentaEntregaCliente({
    required this.nombreCompleto,
    required this.direccion,
    required this.telefono,
    required this.nacionalidad,
    required this.cedulaPasaporte,
    required this.licenciaConducir,
    this.fechaVencimientoLicencia,
  });

  final String nombreCompleto;
  final String direccion;
  final String telefono;
  final String nacionalidad;
  final String cedulaPasaporte;
  final String licenciaConducir;
  final DateTime? fechaVencimientoLicencia;

  factory RentaEntregaCliente.fromJson(Map<String, dynamic> json) =>
      RentaEntregaCliente(
        nombreCompleto: _text(json['nombreCompleto']),
        direccion: _text(json['direccion']),
        telefono: _text(json['telefono']),
        nacionalidad: _text(json['nacionalidad']),
        cedulaPasaporte: _text(json['cedulaPasaporte']),
        licenciaConducir: _text(json['licenciaConducir']),
        fechaVencimientoLicencia: _nullableDate(
          json['fechaVencimientoLicencia'],
        ),
      );
}

class RentaEntregaVehiculo {
  const RentaEntregaVehiculo({
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.vin,
    required this.color,
    required this.tipo,
    required this.kilometraje,
  });

  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String vin;
  final String color;
  final String tipo;
  final int kilometraje;

  factory RentaEntregaVehiculo.fromJson(Map<String, dynamic> json) =>
      RentaEntregaVehiculo(
        marca: _text(json['marca']),
        modelo: _text(json['modelo']),
        anio: _int(json['anio']),
        placa: _text(json['placa']),
        vin: _text(json['vin']),
        color: _text(json['color']),
        tipo: _text(json['tipo']),
        kilometraje: _int(json['kilometraje']),
      );
}

class RentaEntregaPago {
  const RentaEntregaPago({
    required this.fechaPago,
    required this.metodo,
    required this.monto,
    required this.monedaCodigo,
    required this.montoMonedaLocal,
  });

  final DateTime fechaPago;
  final String metodo;
  final double monto;
  final String monedaCodigo;
  final double montoMonedaLocal;

  factory RentaEntregaPago.fromJson(Map<String, dynamic> json) =>
      RentaEntregaPago(
        fechaPago: _date(json['fechaPago']),
        metodo: _text(json['metodo']),
        monto: _double(json['monto']),
        monedaCodigo: _text(json['monedaCodigo']),
        montoMonedaLocal: _double(json['montoMonedaLocal']),
      );
}

class RentaEntregaAccesorio {
  const RentaEntregaAccesorio({
    required this.idAccesorio,
    required this.nombre,
    this.observaciones,
  });

  final int idAccesorio;
  final String nombre;
  final String? observaciones;

  factory RentaEntregaAccesorio.fromJson(Map<String, dynamic> json) =>
      RentaEntregaAccesorio(
        idAccesorio: _int(json['idAccesorio']),
        nombre: _text(json['nombre']),
        observaciones: _nullableText(json['observaciones']),
      );
}

Map<String, dynamic> _map(Object? value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};
List<dynamic> _list(Object? value) => value is List<dynamic> ? value : const [];
int _int(Object? value) => (value as num?)?.toInt() ?? 0;
double _double(Object? value) => (value as num?)?.toDouble() ?? 0;
String _text(Object? value) => value?.toString() ?? '';
String? _nullableText(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

DateTime _date(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '')?.toLocal() ?? DateTime(1900);
DateTime? _nullableDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString())?.toLocal();

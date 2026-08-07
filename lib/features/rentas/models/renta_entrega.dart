class RentaEntrega {
  const RentaEntrega({
    required this.idRenta,
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
  final String numeroContrato;
  final EntregaEmpresa empresa;
  final EntregaCliente cliente;
  final EntregaVehiculo vehiculo;
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
  final List<EntregaPago> pagos;
  final List<EntregaAccesorio> accesorios;

  double get totalAbonadoLocal =>
      pagos.fold(0, (total, payment) => total + payment.montoMonedaLocal);

  factory RentaEntrega.fromJson(Map<String, dynamic> json) => RentaEntrega(
    idRenta: _int(json['idRenta']),
    numeroContrato: json['numeroContrato']?.toString() ?? '',
    empresa: EntregaEmpresa.fromJson(json['empresa'] as Map<String, dynamic>),
    cliente: EntregaCliente.fromJson(json['cliente'] as Map<String, dynamic>),
    vehiculo: EntregaVehiculo.fromJson(
      json['vehiculo'] as Map<String, dynamic>,
    ),
    fechaInicio: _date(json['fechaInicio']),
    fechaFin: _date(json['fechaFin']),
    precioPorDiaPactado: _double(json['precioPorDiaPactado']),
    cantidadDias: _int(json['cantidadDias']),
    subtotal: _double(json['subtotal']),
    impuestos: _double(json['impuestos']),
    descuentos: _double(json['descuentos']),
    deposito: _double(json['deposito']),
    total: _double(json['total']),
    monedaCodigo: json['monedaCodigo']?.toString() ?? '',
    monedaSimbolo: json['monedaSimbolo']?.toString() ?? '',
    observaciones: json['observaciones']?.toString(),
    pagos: (json['pagos'] as List? ?? const [])
        .map((x) => EntregaPago.fromJson(x as Map<String, dynamic>))
        .toList(growable: false),
    accesorios: (json['accesorios'] as List? ?? const [])
        .map((x) => EntregaAccesorio.fromJson(x as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class EntregaEmpresa {
  const EntregaEmpresa({
    required this.nombreComercial,
    required this.rnc,
    required this.telefono,
    required this.email,
    required this.direccion,
    this.logoUrl,
  });
  final String nombreComercial, rnc, telefono, email, direccion;
  final String? logoUrl;
  factory EntregaEmpresa.fromJson(Map<String, dynamic> json) => EntregaEmpresa(
    nombreComercial: json['nombreComercial']?.toString() ?? '',
    rnc: json['rnc']?.toString() ?? '',
    telefono: json['telefono']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    direccion: json['direccion']?.toString() ?? '',
    logoUrl: json['logoUrl']?.toString(),
  );
}

class EntregaCliente {
  const EntregaCliente({
    required this.nombreCompleto,
    required this.direccion,
    required this.telefono,
    required this.nacionalidad,
    required this.cedulaPasaporte,
    required this.licenciaConducir,
    required this.fechaVencimientoLicencia,
  });
  final String nombreCompleto, direccion, telefono, nacionalidad;
  final String cedulaPasaporte, licenciaConducir;
  final DateTime? fechaVencimientoLicencia;
  factory EntregaCliente.fromJson(Map<String, dynamic> json) => EntregaCliente(
    nombreCompleto: json['nombreCompleto']?.toString() ?? '',
    direccion: json['direccion']?.toString() ?? '',
    telefono: json['telefono']?.toString() ?? '',
    nacionalidad: json['nacionalidad']?.toString() ?? '',
    cedulaPasaporte: json['cedulaPasaporte']?.toString() ?? '',
    licenciaConducir: json['licenciaConducir']?.toString() ?? '',
    fechaVencimientoLicencia: json['fechaVencimientoLicencia'] == null
        ? null
        : _date(json['fechaVencimientoLicencia']),
  );
}

class EntregaVehiculo {
  const EntregaVehiculo({
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    required this.vin,
    required this.color,
    required this.tipo,
    required this.kilometraje,
  });
  final String marca, modelo, placa, vin, color, tipo;
  final int anio, kilometraje;
  factory EntregaVehiculo.fromJson(Map<String, dynamic> json) =>
      EntregaVehiculo(
        marca: json['marca']?.toString() ?? '',
        modelo: json['modelo']?.toString() ?? '',
        anio: _int(json['anio']),
        placa: json['placa']?.toString() ?? '',
        vin: json['vin']?.toString() ?? '',
        color: json['color']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? '',
        kilometraje: _int(json['kilometraje']),
      );
}

class EntregaPago {
  const EntregaPago({
    required this.fechaPago,
    required this.metodo,
    required this.monto,
    required this.monedaCodigo,
    required this.montoMonedaLocal,
  });
  final DateTime fechaPago;
  final String metodo, monedaCodigo;
  final double monto, montoMonedaLocal;
  factory EntregaPago.fromJson(Map<String, dynamic> json) => EntregaPago(
    fechaPago: _date(json['fechaPago']),
    metodo: json['metodo']?.toString() ?? '',
    monto: _double(json['monto']),
    monedaCodigo: json['monedaCodigo']?.toString() ?? '',
    montoMonedaLocal: _double(json['montoMonedaLocal']),
  );
}

class EntregaAccesorio {
  const EntregaAccesorio({
    required this.idAccesorio,
    required this.nombre,
    this.observaciones,
  });
  final int idAccesorio;
  final String nombre;
  final String? observaciones;
  factory EntregaAccesorio.fromJson(Map<String, dynamic> json) =>
      EntregaAccesorio(
        idAccesorio: _int(json['idAccesorio']),
        nombre: json['nombre']?.toString() ?? '',
        observaciones: json['observaciones']?.toString(),
      );
}

int _int(Object? value) => (value as num?)?.toInt() ?? 0;
double _double(Object? value) => (value as num?)?.toDouble() ?? 0;
DateTime _date(Object? value) => DateTime.parse(value.toString()).toLocal();

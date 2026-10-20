class PoliticaRentaDto {
  const PoliticaRentaDto({
    required this.minimoDias,
    this.capturarHorasPeriodoAlquiler = true,
  });
  final bool capturarHorasPeriodoAlquiler;
  final int minimoDias;

  factory PoliticaRentaDto.fromJson(Map<String, dynamic> json) =>
      PoliticaRentaDto(
        minimoDias: (json['minimoDias'] as num).toInt(),
        capturarHorasPeriodoAlquiler:
            json['capturarHorasPeriodoAlquiler'] != false,
      );

  int dias(DateTime inicio, DateTime fin) {
    DateTime fecha(DateTime value) {
      final local = value.toUtc().subtract(const Duration(hours: 4));
      return DateTime.utc(local.year, local.month, local.day);
    }

    return (fecha(fin).difference(fecha(inicio)).inDays + 1).clamp(
      1,
      2147483647,
    );
  }

  bool permiteDescuento(DateTime inicio, DateTime fin) =>
      fin.isAfter(inicio) && dias(inicio, fin) > minimoDias;

  String? validar(
    DateTime inicio,
    DateTime fin,
    double descuento, {
    bool permitirDescuentoMinimo = false,
  }) {
    if (!fin.isAfter(inicio)) {
      return 'La fecha final debe ser posterior a la fecha inicial.';
    }
    final cantidad = dias(inicio, fin);
    if (cantidad < minimoDias) {
      return 'La renta debe tener al menos $minimoDias días.';
    }
    if (cantidad == minimoDias && descuento > 0 && !permitirDescuentoMinimo) {
      return 'No se permiten descuentos para rentas de $minimoDias días.';
    }
    return null;
  }
}

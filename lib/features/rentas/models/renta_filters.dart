enum RentaListScope { active, history }

class RentaFilters {
  const RentaFilters({
    this.idCliente,
    this.idVehiculo,
    this.fechaDesde,
    this.fechaHasta,
  });

  final int? idCliente;
  final int? idVehiculo;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;

  bool get isEmpty =>
      idCliente == null &&
      idVehiculo == null &&
      fechaDesde == null &&
      fechaHasta == null;

  RentaFilters copyWith({DateTime? fechaDesde, DateTime? fechaHasta}) =>
      RentaFilters(
        idCliente: idCliente,
        idVehiculo: idVehiculo,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
      );
}

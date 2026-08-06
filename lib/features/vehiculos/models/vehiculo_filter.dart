class VehiculoFilter {
  const VehiculoFilter({this.idTipo, this.idCombustible, this.marca});

  final int? idTipo;
  final int? idCombustible;
  final String? marca;

  bool get isEmpty =>
      idTipo == null && idCombustible == null && (marca?.isEmpty ?? true);

  VehiculoFilter copyWith({
    int? idTipo,
    int? idCombustible,
    String? marca,
    bool clearTipo = false,
    bool clearCombustible = false,
    bool clearMarca = false,
  }) {
    return VehiculoFilter(
      idTipo: clearTipo ? null : idTipo ?? this.idTipo,
      idCombustible: clearCombustible
          ? null
          : idCombustible ?? this.idCombustible,
      marca: clearMarca ? null : marca ?? this.marca,
    );
  }

  Map<String, String> toQueryParameters({required bool incluirInactivos}) => {
    'incluirInactivos': '$incluirInactivos',
    if (idTipo != null) 'idTipo': '$idTipo',
    if (idCombustible != null) 'idCombustible': '$idCombustible',
    if (marca?.trim().isNotEmpty == true) 'marca': marca!.trim(),
  };
}

class FotoVehiculo {
  const FotoVehiculo({required this.idFoto,required this.url,required this.esPrincipal,required this.orden,required this.rowVersion,this.titulo,this.textoAlternativo});
  final int idFoto;final String url;final bool esPrincipal;final int orden;final String rowVersion;final String? titulo;final String? textoAlternativo;
  factory FotoVehiculo.fromJson(Map<String,dynamic> j)=>FotoVehiculo(idFoto:(j['idFoto'] as num).toInt(),url:j['url']?.toString()??'',esPrincipal:j['esPrincipal'] as bool? ?? false,orden:(j['orden'] as num?)?.toInt()??0,rowVersion:j['rowVersion']?.toString()??'',titulo:j['titulo']?.toString(),textoAlternativo:j['textoAlternativo']?.toString());
}

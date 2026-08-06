class Accesorio {
  const Accesorio({required this.id, required this.codigo, required this.nombre, required this.activo, this.icono, this.descripcion});
  final int id; final String codigo; final String nombre; final bool activo; final String? icono; final String? descripcion;
  factory Accesorio.fromJson(Map<String,dynamic> j)=>Accesorio(id:(j['idAccesorio'] as num).toInt(),codigo:j['codigo']?.toString()??'',nombre:j['nombre']?.toString()??'',activo:j['activo'] as bool? ?? true,icono:j['icono']?.toString(),descripcion:j['descripcion']?.toString());
}

class VehiculoAccesorio {
  const VehiculoAccesorio({required this.idVehiculoAccesorio,required this.idAccesorio,required this.nombre,this.icono,this.observaciones});
  final int idVehiculoAccesorio;final int idAccesorio;final String nombre;final String? icono;final String? observaciones;
  factory VehiculoAccesorio.fromJson(Map<String,dynamic> j)=>VehiculoAccesorio(idVehiculoAccesorio:(j['idVehiculoAccesorio'] as num).toInt(),idAccesorio:(j['idAccesorio'] as num).toInt(),nombre:j['nombre']?.toString()??'',icono:j['icono']?.toString(),observaciones:j['observaciones']?.toString());
}

import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';
import '../models/foto_vehiculo.dart';
import '../models/vehiculo_accesorio.dart';

class VehiculoMediaService {
  VehiculoMediaService({ApiClient? apiClient}):_api=apiClient??ApiClient(); final ApiClient _api;
  List<T> _list<T>(Map<String,dynamic> json,T Function(Map<String,dynamic>) map){final data=json['data'];if(data is! List)return const [];return data.map((e)=>map(e as Map<String,dynamic>)).toList();}
  T _one<T>(Map<String,dynamic> json,T Function(Map<String,dynamic>) map){final data=json['data'];if(data is! Map<String,dynamic>)throw const ApiException(message:'La API no devolvió los datos esperados.');return map(data);}
  Future<List<Accesorio>> catalogo()=>_api.getJson(ApiConfig.accesorios).then((j)=>_list(j,Accesorio.fromJson));
  Future<List<VehiculoAccesorio>> accesorios(int id)=>_api.getJson('${ApiConfig.vehiculos}/$id/accesorios').then((j)=>_list(j,VehiculoAccesorio.fromJson));
  Future<void> asignar(int vehiculo,int accesorio)=>_api.postJson('${ApiConfig.vehiculos}/$vehiculo/accesorios',{'idAccesorio':accesorio});
  Future<void> retirar(int vehiculo,int accesorio)=>_api.deleteJson('${ApiConfig.vehiculos}/$vehiculo/accesorios/$accesorio');
  Future<List<FotoVehiculo>> fotos(int id)=>_api.getJson('${ApiConfig.vehiculos}/$id/fotos').then((j)=>_list(j,FotoVehiculo.fromJson));
  Future<FotoVehiculo> subir(int id,List<int> bytes,String name,String type,{bool principal=false}) async=>_one(await _api.multipart('${ApiConfig.vehiculos}/$id/fotos',bytes:bytes,fileName:name,contentType:type,fields:{'esPrincipal':'$principal','orden':'0'}),FotoVehiculo.fromJson);
  Future<void> principal(int v,int f)=>_api.patchJson('${ApiConfig.vehiculos}/$v/fotos/$f/principal');
  Future<void> eliminarFoto(int v,int f)=>_api.deleteJson('${ApiConfig.vehiculos}/$v/fotos/$f');
}

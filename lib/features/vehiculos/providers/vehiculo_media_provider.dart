import 'package:flutter/foundation.dart';
import '../models/foto_vehiculo.dart';
import '../models/vehiculo_accesorio.dart';
import '../services/vehiculo_media_service.dart';

class VehiculoMediaProvider extends ChangeNotifier {
  VehiculoMediaProvider({VehiculoMediaService? service}):_service=service??VehiculoMediaService(); final VehiculoMediaService _service;
  List<Accesorio> catalogo=const[];List<VehiculoAccesorio> asignados=const[];List<FotoVehiculo> fotos=const[];bool loading=false;String? error;
  Future<void> cargar(int id) async{loading=true;error=null;notifyListeners();try{final values=await Future.wait([_service.catalogo(),_service.accesorios(id),_service.fotos(id)]);catalogo=values[0] as List<Accesorio>;asignados=values[1] as List<VehiculoAccesorio>;fotos=values[2] as List<FotoVehiculo>;}catch(e){error=e.toString();}finally{loading=false;notifyListeners();}}
  Future<bool> alternar(int vehiculo,Accesorio item,bool value) async{try{if(value){await _service.asignar(vehiculo,item.id);}else{await _service.retirar(vehiculo,item.id);}await cargar(vehiculo);return true;}catch(e){error=e.toString();notifyListeners();return false;}}
  Future<bool> subir(int vehiculo,List<int> bytes,String name,String type) async{try{await _service.subir(vehiculo,bytes,name,type,principal:fotos.isEmpty);await cargar(vehiculo);return true;}catch(e){error=e.toString();notifyListeners();return false;}}
  Future<void> hacerPrincipal(int v,int f)async{await _service.principal(v,f);await cargar(v);}
  Future<void> eliminar(int v,int f)async{await _service.eliminarFoto(v,f);await cargar(v);}
}

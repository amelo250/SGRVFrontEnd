import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehiculo_media_provider.dart';

class VehiculoAccesoriosSection extends StatelessWidget {
  const VehiculoAccesoriosSection({required this.idVehiculo,super.key});final int idVehiculo;
  @override Widget build(BuildContext context){final p=context.watch<VehiculoMediaProvider>();if(p.loading)return const Center(child:CircularProgressIndicator());if(p.error!=null)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[const Icon(Icons.cloud_off_rounded,size:42),const SizedBox(height:12),Text(p.error!,textAlign:TextAlign.center),TextButton.icon(onPressed:()=>p.cargar(idVehiculo),icon:const Icon(Icons.refresh),label:const Text('Reintentar'))]));
    final selected=p.asignados.map((x)=>x.idAccesorio).toSet();return ListView(children:[Card(child:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Equipamiento y accesorios',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:6),Text('${selected.length} accesorios asignados',style:Theme.of(context).textTheme.bodyMedium),const SizedBox(height:18),Wrap(spacing:12,runSpacing:12,children:p.catalogo.map((a){final active=selected.contains(a.id);return FilterChip(selected:active,avatar:Icon(_icon(a.codigo),size:19),label:Text(a.nombre),onSelected:(value)=>p.alternar(idVehiculo,a,value));}).toList())])))]);}
  IconData _icon(String code){final c=code.toUpperCase();if(c.contains('GPS'))return Icons.navigation_rounded;if(c.contains('LED'))return Icons.lightbulb_rounded;if(c.contains('MUS'))return Icons.speaker_rounded;if(c.contains('WIFI'))return Icons.wifi_rounded;return Icons.extension_rounded;}
}

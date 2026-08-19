import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/pages/auth_gate.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/calendario/providers/calendario_provider.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';
import 'package:sgrv_frontend/features/proveedores/providers/proveedor_vehiculo_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/providers/reservacion_provider.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehicle_catalog_provider.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_form_provider.dart';
import 'package:sgrv_frontend/features/pagos/providers/pago_provider.dart';
import 'package:sgrv_frontend/features/gastos/providers/gasto_provider.dart';
import 'package:sgrv_frontend/features/vehiculos/providers/vehiculo_media_provider.dart';
import 'package:sgrv_frontend/features/configuracion/providers/configuracion_provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/documento_cliente_provider.dart';
import 'package:sgrv_frontend/features/mantenimientos/providers/mantenimiento_provider.dart';
import 'package:sgrv_frontend/features/administracion/providers/administracion_provider.dart';
import 'package:sgrv_frontend/features/contabilidad/providers/contabilidad_provider.dart';

class SgrvApp extends StatelessWidget {
  const SgrvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
        ChangeNotifierProvider(create: (_) => ProveedorVehiculoProvider()),
        ChangeNotifierProvider(create: (_) => VehiculoProvider()),
        ChangeNotifierProvider(create: (_) => VehicleCatalogProvider()),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => ReservacionProvider()),
        ChangeNotifierProvider(create: (_) => RentaProvider()),
        ChangeNotifierProvider(create: (_) => PagoProvider()),
        ChangeNotifierProvider(create: (_) => PagoFormProvider()),
        ChangeNotifierProvider(create: (_) => GastoProvider()),
        ChangeNotifierProvider(create: (_) => VehiculoMediaProvider()),
        ChangeNotifierProvider(create: (_) => ConfiguracionProvider()),
        ChangeNotifierProvider(create: (_) => DocumentoClienteProvider()),
        ChangeNotifierProvider(create: (_) => CalendarioProvider()),
        ChangeNotifierProvider(create: (_) => MantenimientoProvider()),
        ChangeNotifierProvider(create: (_) => AdministracionProvider()),
        ChangeNotifierProvider(create: (_) => ContabilidadProvider()),
      ],
      child: MaterialApp(
        title: 'SGRV',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:sgrv_frontend/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa los nombres de meses, días y formatos dominicanos.
  await initializeDateFormatting('es_DO');

  // Establece el locale predeterminado de toda la aplicación.
  Intl.defaultLocale = 'es_DO';

  runApp(const SgrvApp());
}

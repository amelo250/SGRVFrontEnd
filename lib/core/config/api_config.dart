class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5083',
  );

  static const Duration timeout = Duration(seconds: 30);

  static const String login = '$baseUrl/api/Auth/login';
  static const String empresas = '$baseUrl/api/empresas';
  static const String clientes = '$baseUrl/api/clientes';
  static const String reservaciones = '$baseUrl/api/reservaciones';
  static const String rentas = '$baseUrl/api/rentas';
  static const String pagos = '$baseUrl/api/pagos';
  static const String gastos = '$baseUrl/api/gastos';
  static const String calendario = '$baseUrl/api/calendario';
  static const String vehiculos = '$baseUrl/api/vehiculos';
  static const String accesorios = '$baseUrl/api/accesorios';
  static const String configuracionCatalogos =
      '$baseUrl/api/configuracion/catalogos';
  static const String catalogs = '$baseUrl/api/catalogos';
  static const String proveedoresVehiculos =
      '$baseUrl/api/proveedoresvehiculos';
  static const String mantenimientos = '$baseUrl/api/mantenimientos';
  static const String dashboardTasks = '$baseUrl/api/dashboard/tareas';
  static const String dashboardSummary = '$baseUrl/api/dashboard/resumen';
  static const String administracionResumen =
      '$baseUrl/api/administracion/resumen';
  static const String administracionRoles = '$baseUrl/api/administracion/roles';
  static const String usuarios = '$baseUrl/api/usuarios';
  static const String contabilidad = '$baseUrl/api/contabilidad/resumen';
}

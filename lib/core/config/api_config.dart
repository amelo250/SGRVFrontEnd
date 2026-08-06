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
  static const String vehiculos = '$baseUrl/api/vehiculos';
  static const String accesorios = '$baseUrl/api/accesorios';
  static const String catalogs = '$baseUrl/api/catalogos';
  static const String proveedoresVehiculos =
      '$baseUrl/api/proveedoresvehiculos';
}

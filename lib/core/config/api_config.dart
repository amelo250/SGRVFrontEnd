class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'https://localhost:7206',
    defaultValue: 'http://10.0.2.2:5083',
  );

  static const Duration timeout = Duration(seconds: 30);

  static const String login = '$baseUrl/api/Auth/login';
  static const String empresas = '$baseUrl/api/empresas';
  static const String clientes = '$baseUrl/api/clientes';
  static const String vehiculos = '$baseUrl/api/vehiculos';
}

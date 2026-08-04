class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.timestamp,
  });

  final bool success;
  final String message;
  final T? data;
  final Object? errors;
  final DateTime? timestamp;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? value) parseData,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : parseData(json['data']),
      errors: json['errors'],
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? ''),
    );
  }
}

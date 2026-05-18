import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const String baseUrl = 'http://localhost:3000';
  static String? _authToken;
  static void Function()? onUnauthorized;

  // Injetáveis em testes
  static http.Client? httpClient;
  static List<Duration>? retryDelays;

  static List<Duration> get _retryDelays =>
      retryDelays ??
      const [
        Duration(milliseconds: 800),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ];

  static http.Client get _client => httpClient ?? http.Client();

  static void setToken(String token) => _authToken = token;
  static void clearToken() => _authToken = null;
  static String get currentToken => _authToken ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  static Future<dynamic> get(String path) =>
      _withRetry(() => _client.get(Uri.parse('$baseUrl$path'), headers: _headers));

  static Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _withRetry(() => _client.post(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          ));

  static Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _withRetry(() => _client.patch(
            Uri.parse('$baseUrl$path'),
            headers: _headers,
            body: jsonEncode(body),
          ));

  static Future<dynamic> delete(String path) =>
      _withRetry(() => _client.delete(Uri.parse('$baseUrl$path'), headers: _headers));

  static Future<dynamic> _withRetry(
    Future<http.Response> Function() request,
  ) async {
    final delays = _retryDelays;
    for (int attempt = 0; attempt <= delays.length; attempt++) {
      try {
        final response = await request();
        return _handleResponse(response);
      } on SocketException {
        throw ApiException('Sem conexão com a internet');
      } on ApiException catch (e) {
        final isServerError = e.statusCode != null && e.statusCode! >= 500;
        final hasMoreAttempts = attempt < delays.length;
        if (isServerError && hasMoreAttempts) {
          await Future.delayed(delays[attempt]);
          continue;
        }
        rethrow;
      }
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }
    final message = body?['message'] ?? 'Erro desconhecido';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
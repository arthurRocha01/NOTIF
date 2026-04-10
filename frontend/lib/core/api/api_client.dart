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

  static void setToken(String token) => _authToken = token;
  static void clearToken() => _authToken = null;
  static String get currentToken => _authToken ?? '';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  static Future<dynamic> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  static Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  static Future<dynamic> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body?['message'] ?? 'Erro desconhecido';
    throw ApiException(message, statusCode: response.statusCode);
  }
}
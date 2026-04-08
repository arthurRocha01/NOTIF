import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';

class AuthService {
  final http.Client _httpClient;
  final String _baseUrl;

  AuthService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://localhost:3000';

  Future<String> login(String email, String password) async {
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    dynamic body;
    try {
      body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      body = null;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return body['access_token'] as String;
    }

    final message = body?['message'] ?? 'Erro ao autenticar';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<UserModel> fetchUser(String email, String token) async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/users/email/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        sector: data['sectorId'] as String? ?? '',
        role: data['role'] == 'SUPERVISOR'
            ? UserRole.supervisor
            : UserRole.employee,
      );
    }

    throw ApiException('Usuário não encontrado', statusCode: response.statusCode);
  }
}

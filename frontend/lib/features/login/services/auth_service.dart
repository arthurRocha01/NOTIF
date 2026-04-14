import 'dart:convert';
import 'dart:io';

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
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Future<String> login(String email, String password) async {
    try {
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
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  Future<UserModel> fetchUser(String email, String token) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/users/by-email/$email'),
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
          role: data['role'] == 'SUPERVISOR' || data['role'] == 'ADMIN'
              ? UserRole.supervisor
              : UserRole.employee,
          fcmToken: data['fcmToken'] as String?,
        );
      }

      throw ApiException('Usuário não encontrado', statusCode: response.statusCode);
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }
}

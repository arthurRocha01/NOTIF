import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';

class AdminUserService {
  final http.Client _httpClient;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 20);

  AdminUserService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
  }

  UserModel _parseUser(Map<String, dynamic> data) => UserModel(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        sector: data['sectorId'] as String? ?? '',
        role: data['role'] == 'ADMIN'
            ? UserRole.admin
            : data['role'] == 'SUPERVISOR'
                ? UserRole.supervisor
                : UserRole.employee,
        fcmToken: data['fcmToken'] as String?,
      );

  Future<List<UserModel>> getUsers({required String token}) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl/users'), headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => _parseUser(e as Map<String, dynamic>))
            .toList();
      }
      final body = _tryDecode(response.body);
      throw ApiException(
        body?['message']?.toString() ?? 'Erro ao buscar usuários',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on Exception {
      throw ApiException('Tempo limite excedido. Tente novamente.');
    }
  }

  Future<UserModel> createUser({
    required String token,
    required String name,
    required String email,
    required String password,
    required String role,
    required String sectorId,
  }) async {
    try {
      final response = await _httpClient
          .post(
            Uri.parse('$_baseUrl/users'),
            headers: _headers(token),
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
              'sectorId': sectorId,
              'fcmToken': null,
            }),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUser(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final body = _tryDecode(response.body);
      throw ApiException(
        body?['message']?.toString() ?? 'Erro ao criar usuário',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<UserModel> updateUser({
    required String token,
    required String userId,
    String? name,
    String? email,
    String? role,
    String? sectorId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (role != null) body['role'] = role;
      if (sectorId != null) body['sectorId'] = sectorId;

      final response = await _httpClient
          .patch(
            Uri.parse('$_baseUrl/users/$userId'),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return _parseUser(jsonDecode(response.body) as Map<String, dynamic>);
      }
      final errBody = _tryDecode(response.body);
      throw ApiException(
        errBody?['message']?.toString() ?? 'Erro ao atualizar usuário',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> deleteUser({
    required String token,
    required String userId,
  }) async {
    try {
      final response = await _httpClient
          .delete(
            Uri.parse('$_baseUrl/users/$userId'),
            headers: _headers(token),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return;
      }
      final body = _tryDecode(response.body);
      throw ApiException(
        body?['message']?.toString() ?? 'Erro ao deletar usuário',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException('Servidor demorando para responder. Tente novamente.');
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';

class AuthService {
  final http.Client _httpClient;
  final String _baseUrl;
  final List<Duration> _retryDelays;

  static const _timeout = Duration(seconds: 20);
  static const _defaultRetryDelays = [
    Duration(milliseconds: 800),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  AuthService({
    http.Client? httpClient,
    String? baseUrl,
    List<Duration>? retryDelays,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl,
        _retryDelays = retryDelays ?? _defaultRetryDelays;

  Future<T> _withRetry<T>(Future<T> Function() request) async {
    for (int attempt = 0; attempt <= _retryDelays.length; attempt++) {
      try {
        return await request();
      } on ApiException catch (e) {
        final isServerError = e.statusCode != null && e.statusCode! >= 500;
        final hasMoreAttempts = attempt < _retryDelays.length;
        if (isServerError && hasMoreAttempts) {
          await Future.delayed(_retryDelays[attempt]);
          continue;
        }
        rethrow;
      }
    }
    throw StateError('unreachable');
  }

  Future<String> login(String email, String password) {
    return _withRetry(() async {
      try {
        final response = await _httpClient
            .post(
              Uri.parse('$_baseUrl/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': email, 'password': password}),
            )
            .timeout(_timeout);

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
      } on TimeoutException {
        throw ApiException('Servidor demorando para responder. Tente novamente.');
      }
    });
  }

  Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
    required String token,
  }) async {
    try {
      final response = await _httpClient
          .patch(
            Uri.parse('$_baseUrl/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'fcmToken': fcmToken}),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) return;
      dynamic body;
      try {
        body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } catch (_) {}
      throw ApiException(
        body?['message'] ?? 'Erro ao atualizar token FCM',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> updatePassword({
    required String userId,
    required String newPassword,
    String? currentPassword,
    required String token,
  }) async {
    try {
      final body = <String, String>{'password': newPassword};
      if (currentPassword != null) body['currentPassword'] = currentPassword;

      final response = await _httpClient
          .patch(
            Uri.parse('$_baseUrl/users/$userId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) return;
      dynamic responseBody;
      try {
        responseBody =
            response.body.isNotEmpty ? jsonDecode(response.body) : null;
      } catch (_) {}
      throw ApiException(
        responseBody?['message'] ?? 'Erro ao atualizar senha',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<UserModel> fetchUser(String email, String token) {
    return _withRetry(() async {
      try {
        final response = await _httpClient
            .get(
              Uri.parse('$_baseUrl/users/by-email/$email'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return UserModel(
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
        }

        throw ApiException('Usuário não encontrado', statusCode: response.statusCode);
      } on SocketException {
        throw ApiException('Sem conexão com a internet');
      } on TimeoutException {
        throw ApiException('Servidor demorando para responder. Tente novamente.');
      }
    });
  }
}

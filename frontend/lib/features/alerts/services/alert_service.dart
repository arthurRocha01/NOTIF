import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';

class AlertServiceException implements Exception {
  final String message;
  final int? statusCode;

  AlertServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'AlertServiceException: $message';
}

class AlertService {
  final http.Client _httpClient;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 20);

  AlertService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<AlertModel>> getNotifications({required String token}) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl/notifications'), headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao buscar notificações',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<AlertModel> createNotification({
    required String token,
    required String authorId,
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    String? sectorId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'message': message,
        'level': level.backendValue,
        'slaMinutes': slaMinutes,
        'requiresAcknowledgment':
            level == AlertLevel.critical ? true : requiresAcknowledgment,
        'authorId': authorId,
        if (sectorId != null) 'sectorId': sectorId,
      };

      final response = await _httpClient
          .post(Uri.parse('$_baseUrl/notifications'),
              headers: _headers(token), body: jsonEncode(payload))
          .timeout(_timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AlertModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao criar notificação',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<List<AssignmentModel>> getMyAssignments({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _httpClient
          .get(Uri.parse('$_baseUrl/assignments/user/$userId'), headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao buscar atribuições',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> markAsViewed({
    required String assignmentId,
    required String token,
  }) async {
    try {
      final response = await _httpClient
          .post(Uri.parse('$_baseUrl/assignments/$assignmentId/view'),
              headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) return;
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao visualizar notificação',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> acknowledge({
    required String assignmentId,
    required String token,
  }) async {
    try {
      final response = await _httpClient
          .post(Uri.parse('$_baseUrl/assignments/$assignmentId/acknowledge'),
              headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) return;
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao confirmar ciência',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> syncDeliveries({
    required String userId,
    required String token,
  }) async {
    try {
      final response = await _httpClient
          .post(Uri.parse('$_baseUrl/assignments/sync/$userId'),
              headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) return;
      final body = _tryDecode(response.body);
      throw AlertServiceException(
        body?['message'] ?? 'Erro ao sincronizar entregas',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw AlertServiceException('Sem conexão com a internet');
    } on TimeoutException {
      throw AlertServiceException('Servidor demorando para responder. Tente novamente.');
    }
  }

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
  }
}

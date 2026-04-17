import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class AdminSectorService {
  final http.Client _httpClient;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 20);

  AdminSectorService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return body.isNotEmpty ? jsonDecode(body) as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<SectorModel> createSector({
    required String token,
    required String name,
  }) async {
    try {
      final response = await _httpClient
          .post(Uri.parse('$_baseUrl/sectors'),
              headers: _headers(token), body: jsonEncode({'name': name}))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SectorModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      final errBody = _tryDecode(response.body);
      throw ApiException(
        errBody?['message']?.toString() ?? 'Erro ao criar setor',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException(
          'Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<SectorModel> updateSector({
    required String token,
    required String sectorId,
    required String name,
  }) async {
    try {
      final response = await _httpClient
          .patch(Uri.parse('$_baseUrl/sectors/$sectorId'),
              headers: _headers(token), body: jsonEncode({'name': name}))
          .timeout(_timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SectorModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      final errBody = _tryDecode(response.body);
      throw ApiException(
        errBody?['message']?.toString() ?? 'Erro ao atualizar setor',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException(
          'Servidor demorando para responder. Tente novamente.');
    }
  }

  Future<void> deleteSector({
    required String token,
    required String sectorId,
  }) async {
    try {
      final response = await _httpClient
          .delete(Uri.parse('$_baseUrl/sectors/$sectorId'),
              headers: _headers(token))
          .timeout(_timeout);
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) {
        return;
      }
      final errBody = _tryDecode(response.body);
      throw ApiException(
        errBody?['message']?.toString() ?? 'Erro ao deletar setor',
        statusCode: response.statusCode,
      );
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    } on TimeoutException {
      throw ApiException(
          'Servidor demorando para responder. Tente novamente.');
    }
  }
}

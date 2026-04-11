import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class SectorServiceException implements Exception {
  final String message;
  final int? statusCode;

  const SectorServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'SectorServiceException: $message';
}

class SectorService {
  final http.Client _httpClient;
  final String _baseUrl;

  SectorService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<List<SectorModel>> getSectors({required String token}) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_baseUrl/sectors'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        return list
            .map((e) => SectorModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      Map<String, dynamic>? body;
      try {
        body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : null;
      } catch (_) {}
      throw SectorServiceException(
        body?['message']?.toString() ?? 'Erro ao buscar setores',
        statusCode: response.statusCode,
      );
    } on SectorServiceException {
      rethrow;
    } on SocketException {
      throw const SectorServiceException('Sem conexão com a internet');
    }
  }
}

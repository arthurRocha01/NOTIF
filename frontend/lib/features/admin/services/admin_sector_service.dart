import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class AdminSectorService {
  final http.Client _httpClient;
  final String _baseUrl;

  AdminSectorService({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiClient.baseUrl;

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<SectorModel> createSector({
    required String token,
    required String name,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/sectors'),
        headers: _headers(token),
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SectorModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException('Erro ao criar setor', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  Future<SectorModel> updateSector({
    required String token,
    required String sectorId,
    required String name,
  }) async {
    try {
      final response = await _httpClient.patch(
        Uri.parse('$_baseUrl/sectors/$sectorId'),
        headers: _headers(token),
        body: jsonEncode({'name': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SectorModel.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw ApiException('Erro ao atualizar setor', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }

  Future<void> deleteSector({
    required String token,
    required String sectorId,
  }) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$_baseUrl/sectors/$sectorId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200 ||
          response.statusCode == 204 ||
          response.statusCode == 201) return;
      throw ApiException('Erro ao deletar setor', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException('Sem conexão com a internet');
    }
  }
}

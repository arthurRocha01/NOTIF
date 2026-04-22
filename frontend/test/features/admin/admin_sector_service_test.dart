import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late AdminSectorService service;

  const baseUrl = 'http://localhost:3000';
  const token = 'test-token';

  setUp(() {
    registerFallbackValue(FakeUri());
    mockClient = MockHttpClient();
    service = AdminSectorService(httpClient: mockClient, baseUrl: baseUrl);
  });

  final sectorJson = {'id': 'sector-1', 'name': 'TI'};

  // ---------------------------------------------------------------------------
  // createSector
  // ---------------------------------------------------------------------------
  group('AdminSectorService.createSector', () {
    test('chama POST /sectors e retorna SectorModel', () async {
      Uri? capturedUri;
      String? capturedBody;

      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        capturedBody =
            inv.namedArguments[const Symbol('body')] as String;
        return http.Response(jsonEncode(sectorJson), 201);
      });

      final result =
          await service.createSector(token: token, name: 'TI');

      expect(capturedUri?.path, equals('/sectors'));
      final body = jsonDecode(capturedBody!);
      expect(body['name'], equals('TI'));
      expect(result, isA<SectorModel>());
      expect(result.name, equals('TI'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Erro', 400));

      await expectLater(
        () => service.createSector(token: token, name: 'TI'),
        throwsA(isA<ApiException>()),
      );
    });

    test('lança ApiException em SocketException', () async {
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(const SocketException('no internet'));

      await expectLater(
        () => service.createSector(token: token, name: 'TI'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateSector
  // ---------------------------------------------------------------------------
  group('AdminSectorService.updateSector', () {
    test('chama PATCH /sectors/:id com o novo nome', () async {
      Uri? capturedUri;
      String? capturedBody;

      when(() => mockClient.patch(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        capturedBody =
            inv.namedArguments[const Symbol('body')] as String;
        return http.Response(
            jsonEncode({'id': 'sector-1', 'name': 'RH'}), 200);
      });

      final result = await service.updateSector(
          token: token, sectorId: 'sector-1', name: 'RH');

      expect(capturedUri?.path, endsWith('/sectors/sector-1'));
      final body = jsonDecode(capturedBody!);
      expect(body['name'], equals('RH'));
      expect(result.name, equals('RH'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.patch(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Erro', 404));

      await expectLater(
        () => service.updateSector(
            token: token, sectorId: 'sector-1', name: 'RH'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteSector
  // ---------------------------------------------------------------------------
  group('AdminSectorService.deleteSector', () {
    test('chama DELETE /sectors/:id', () async {
      Uri? capturedUri;

      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        return http.Response('', 200);
      });

      await service.deleteSector(token: token, sectorId: 'sector-1');

      expect(capturedUri?.path, endsWith('/sectors/sector-1'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Erro', 404));

      await expectLater(
        () => service.deleteSector(token: token, sectorId: 'sector-1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

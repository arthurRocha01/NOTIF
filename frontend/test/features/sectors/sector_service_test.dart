import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late SectorService service;

  const baseUrl = 'http://localhost:3000';
  const token = 'test-token';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    mockClient = MockHttpClient();
    service = SectorService(httpClient: mockClient, baseUrl: baseUrl);
  });

  final sectorJson = [
    {'id': 'uuid-ti', 'name': 'TI'},
    {'id': 'uuid-rh', 'name': 'RH'},
    {'id': 'uuid-ops', 'name': 'Operações'},
  ];

  group('SectorService.getSectors', () {
    test('retorna lista de SectorModel em sucesso', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(sectorJson), 200));

      final result = await service.getSectors(token: token);

      expect(result, hasLength(3));
      expect(result.first.id, equals('uuid-ti'));
      expect(result.first.name, equals('TI'));
      expect(result.last.name, equals('Operações'));
    });

    test('lança SectorServiceException em status != 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer(
              (_) async => http.Response('{"message":"Unauthorized"}', 401));

      expect(
        () => service.getSectors(token: token),
        throwsA(isA<SectorServiceException>()),
      );
    });

    test('lança SectorServiceException em SocketException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SectorServiceException('Sem conexão com a internet'));

      expect(
        () => service.getSectors(token: token),
        throwsA(isA<SectorServiceException>()),
      );
    });

    test('SectorModel.fromJson mapeia id e name corretamente', () {
      final model = SectorModel.fromJson({'id': 'abc-123', 'name': 'Financeiro'});
      expect(model.id, equals('abc-123'));
      expect(model.name, equals('Financeiro'));
    });
  });
}

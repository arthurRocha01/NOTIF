import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late AuthService sut;

  setUp(() {
    mockClient = MockHttpClient();
    sut = AuthService(httpClient: mockClient);
    registerFallbackValue(Uri());
  });

  group('AuthService.login', () {
    test('retorna token quando credenciais são válidas', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'access_token': 'jwt-token-123'}),
          201,
        ),
      );

      final token = await sut.login('user@test.com', 'senha123');

      expect(token, equals('jwt-token-123'));
    });

    test('lança ApiException com status 401 quando credenciais são inválidas',
        () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Credenciais inválidas'}),
          401,
        ),
      );

      expect(
        () => sut.login('wrong@test.com', 'errada'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 401)
              .having((e) => e.message, 'message', 'Credenciais inválidas'),
        ),
      );
    });

    test('lança ApiException em erro de servidor (500)', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => http.Response('Internal Server Error', 500),
      );

      expect(
        () => sut.login('user@test.com', 'senha123'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });
  });

  group('AuthService.fetchUser', () {
    test('retorna UserModel quando o usuário existe', () async {
      when(
        () => mockClient.get(
          any(),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'uuid-123',
            'name': 'João Silva',
            'email': 'joao@test.com',
            'role': 'EMPLOYEE',
            'sectorId': 'sector-abc',
          }),
          200,
        ),
      );

      final user = await sut.fetchUser('joao@test.com', 'jwt-token-123');

      expect(user.id, equals('uuid-123'));
      expect(user.name, equals('João Silva'));
      expect(user.email, equals('joao@test.com'));
      expect(user.role, equals(UserRole.employee));
      expect(user.sector, equals('sector-abc'));
    });

    test('mapeia role SUPERVISOR corretamente', () async {
      when(
        () => mockClient.get(
          any(),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'uuid-456',
            'name': 'Roberta Lima',
            'email': 'roberta@test.com',
            'role': 'SUPERVISOR',
            'sectorId': 'sector-xyz',
          }),
          200,
        ),
      );

      final user = await sut.fetchUser('roberta@test.com', 'jwt-token-123');

      expect(user.role, equals(UserRole.supervisor));
    });

    test('lança ApiException quando usuário não é encontrado', () async {
      when(
        () => mockClient.get(
          any(),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'message': 'Not Found'}),
          404,
        ),
      );

      expect(
        () => sut.fetchUser('ghost@test.com', 'jwt-token-123'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });
  });
}

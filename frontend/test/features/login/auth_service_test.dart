import 'dart:convert';
import 'dart:io';

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
    sut = AuthService(httpClient: mockClient, retryDelays: const []);
    registerFallbackValue(Uri());
  });

  // ---------------------------------------------------------------------------
  // AuthService.login
  // ---------------------------------------------------------------------------
  group('AuthService.login', () {
    test('retorna token quando credenciais são válidas (200)', () async {
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'access_token': 'jwt-token-123'}), 200),
      );

      final token = await sut.login('user@test.com', 'senha123');

      expect(token, equals('jwt-token-123'));
    });

    test('retorna token quando credenciais são válidas (201)', () async {
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'access_token': 'jwt-token-123'}), 201),
      );

      final token = await sut.login('user@test.com', 'senha123');

      expect(token, equals('jwt-token-123'));
    });

    test('chama o endpoint correto POST /auth/login', () async {
      Uri? capturedUri;
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response(
            jsonEncode({'access_token': 'jwt-token-123'}), 200);
      });

      await sut.login('user@test.com', 'senha123');

      expect(capturedUri?.path, endsWith('/auth/login'));
    });

    test('envia email e password no corpo da requisição', () async {
      String? capturedBody;
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[const Symbol('body')] as String;
        return http.Response(
            jsonEncode({'access_token': 'jwt-token-123'}), 200);
      });

      await sut.login('user@test.com', 'senha123');

      final body = jsonDecode(capturedBody!);
      expect(body['email'], equals('user@test.com'));
      expect(body['password'], equals('senha123'));
    });

    test('lança ApiException(401) quando credenciais são inválidas', () async {
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer(
        (_) async => http.Response(
            jsonEncode({'message': 'Credenciais inválidas'}), 401),
      );

      await expectLater(
        () => sut.login('wrong@test.com', 'errada'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'Credenciais inválidas')),
      );
    });

    test('lança ApiException(500) em erro de servidor', () async {
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response('Internal Server Error', 500));

      await expectLater(
        () => sut.login('user@test.com', 'senha123'),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('lança ApiException sem conexão (SocketException)', () async {
      when(
        () => mockClient.post(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenThrow(const SocketException('No internet'));

      await expectLater(
        () => sut.login('user@test.com', 'senha123'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('internet'))
            .having((e) => e.statusCode, 'statusCode', isNull)),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AuthService.updatePassword
  // ---------------------------------------------------------------------------
  group('AuthService.updatePassword', () {
    test('chama o endpoint correto PATCH /users/:id', () async {
      Uri? capturedUri;
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response('{}', 200);
      });

      await sut.updatePassword(userId: 'user-1', newPassword: 'nova123', token: 'jwt');

      expect(capturedUri?.path, endsWith('/users/user-1'));
    });

    test('envia password e currentPassword no corpo quando fornecidos', () async {
      String? capturedBody;
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[const Symbol('body')] as String;
        return http.Response('{}', 200);
      });

      await sut.updatePassword(
        userId: 'user-1',
        newPassword: 'nova123',
        currentPassword: 'atual123',
        token: 'jwt',
      );

      final body = jsonDecode(capturedBody!);
      expect(body['password'], equals('nova123'));
      expect(body['currentPassword'], equals('atual123'));
    });

    test('NÃO envia currentPassword quando não fornecido', () async {
      String? capturedBody;
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((invocation) async {
        capturedBody = invocation.namedArguments[const Symbol('body')] as String;
        return http.Response('{}', 200);
      });

      await sut.updatePassword(userId: 'user-1', newPassword: 'nova123', token: 'jwt');

      final body = jsonDecode(capturedBody!);
      expect(body['password'], equals('nova123'));
      expect(body.containsKey('currentPassword'), isFalse);
    });

    test('retorna sem exceção em 200', () async {
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer((_) async => http.Response('{}', 200));

      await expectLater(
        sut.updatePassword(userId: 'user-1', newPassword: 'nova123', token: 'jwt'),
        completes,
      );
    });

    test('lança ApiException em erro HTTP', () async {
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenAnswer(
          (_) async => http.Response('{"message":"Não autorizado"}', 401));

      await expectLater(
        sut.updatePassword(userId: 'user-1', newPassword: 'nova123', token: 'jwt'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('lança ApiException sem conexão (SocketException)', () async {
      when(
        () => mockClient.patch(any(),
            headers: any(named: 'headers'), body: any(named: 'body')),
      ).thenThrow(const SocketException('No internet'));

      await expectLater(
        sut.updatePassword(userId: 'user-1', newPassword: 'nova123', token: 'jwt'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('internet'))),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // AuthService.fetchUser
  // ---------------------------------------------------------------------------
  group('AuthService.fetchUser', () {
    test('chama o endpoint correto GET /users/by-email/:email', () async {
      Uri? capturedUri;
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((invocation) async {
        capturedUri = invocation.positionalArguments.first as Uri;
        return http.Response(
          jsonEncode({
            'id': 'uuid-123',
            'name': 'João',
            'email': 'joao@test.com',
            'role': 'EMPLOYEE',
            'sectorId': 'sec-1',
          }),
          200,
        );
      });

      await sut.fetchUser('joao@test.com', 'token');

      expect(capturedUri?.path, contains('/users/by-email/'));
    });

    test('envia Authorization Bearer no header', () async {
      Map<String, String>? capturedHeaders;
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((invocation) async {
        capturedHeaders = invocation.namedArguments[const Symbol('headers')]
            as Map<String, String>;
        return http.Response(
          jsonEncode({
            'id': 'uuid-123',
            'name': 'João',
            'email': 'joao@test.com',
            'role': 'EMPLOYEE',
            'sectorId': 'sec-1',
          }),
          200,
        );
      });

      await sut.fetchUser('joao@test.com', 'my-token');

      expect(capturedHeaders?['Authorization'], equals('Bearer my-token'));
    });

    test('retorna UserModel com todos os campos quando usuário existe', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
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

    test('mapeia role SUPERVISOR para UserRole.supervisor', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
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

    test('mapeia role ADMIN para UserRole.admin', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'uuid-789',
            'name': 'Admin User',
            'email': 'admin@test.com',
            'role': 'ADMIN',
            'sectorId': 'sector-xyz',
          }),
          200,
        ),
      );

      final user = await sut.fetchUser('admin@test.com', 'jwt-token-123');

      expect(user.role, equals(UserRole.admin));
    });

    test('lança ApiException(404) quando usuário não é encontrado', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async =>
            http.Response(jsonEncode({'message': 'Not Found'}), 404),
      );

      await expectLater(
        () => sut.fetchUser('ghost@test.com', 'jwt-token-123'),
        throwsA(
            isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('lança ApiException sem conexão (SocketException)', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenThrow(const SocketException('No internet'));

      await expectLater(
        () => sut.fetchUser('joao@test.com', 'token'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('internet'))),
      );
    });

    test('parseia fcmToken quando retornado pelo backend', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async => http.Response(
          jsonEncode({
            'id': 'uuid-123',
            'name': 'João Silva',
            'email': 'joao@test.com',
            'role': 'EMPLOYEE',
            'sectorId': 'sector-abc',
            'fcmToken': 'token-fcm-abc123',
          }),
          200,
        ),
      );

      final user = await sut.fetchUser('joao@test.com', 'jwt-token-123');

      expect(user.fcmToken, equals('token-fcm-abc123'));
    });

    test('fcmToken é null quando não retornado pelo backend', () async {
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
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

      expect(user.fcmToken, isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Retry — fetchUser
  // ---------------------------------------------------------------------------
  group('AuthService.fetchUser — retry em cold start', () {
    late MockHttpClient retryClient;
    late AuthService retrySut;

    const _userJson = '{"id":"uuid-123","name":"João","email":"joao@test.com","role":"EMPLOYEE","sectorId":"sec-1"}';

    setUp(() {
      retryClient = MockHttpClient();
      retrySut = AuthService(
        httpClient: retryClient,
        retryDelays: const [Duration.zero, Duration.zero, Duration.zero],
      );
      registerFallbackValue(Uri());
    });

    test('retenta em 500 e retorna sucesso na 2ª tentativa', () async {
      var calls = 0;
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async {
        calls++;
        return calls == 1
            ? http.Response('err', 500)
            : http.Response(_userJson, 200);
      });

      final user = await retrySut.fetchUser('joao@test.com', 'token');

      expect(user.id, equals('uuid-123'));
      expect(calls, equals(2));
    });

    test('retenta em 502 e retorna sucesso na 3ª tentativa', () async {
      var calls = 0;
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async {
        calls++;
        return calls < 3
            ? http.Response('err', 502)
            : http.Response(_userJson, 200);
      });

      final user = await retrySut.fetchUser('joao@test.com', 'token');

      expect(user.id, equals('uuid-123'));
      expect(calls, equals(3));
    });

    test('lança ApiException após esgotar 3 retentativas em 500 persistente', () async {
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('err', 500));

      await expectLater(
        () => retrySut.fetchUser('joao@test.com', 'token'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );

      verify(() => retryClient.get(any(), headers: any(named: 'headers')))
          .called(4);
    });

    test('NÃO retenta em 401', () async {
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"message":"Unauthorized"}', 401));

      await expectLater(
        () => retrySut.fetchUser('joao@test.com', 'token'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );

      verify(() => retryClient.get(any(), headers: any(named: 'headers')))
          .called(1);
    });

    test('NÃO retenta em 404', () async {
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response('{"message":"Not Found"}', 404));

      await expectLater(
        () => retrySut.fetchUser('joao@test.com', 'token'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );

      verify(() => retryClient.get(any(), headers: any(named: 'headers')))
          .called(1);
    });

    test('NÃO retenta em SocketException', () async {
      when(() => retryClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('No internet'));

      await expectLater(
        () => retrySut.fetchUser('joao@test.com', 'token'),
        throwsA(isA<ApiException>()
            .having((e) => e.message, 'message', contains('internet'))),
      );

      verify(() => retryClient.get(any(), headers: any(named: 'headers')))
          .called(1);
    });
  });

  // ---------------------------------------------------------------------------
  // Retry — login
  // ---------------------------------------------------------------------------
  group('AuthService.login — retry em cold start', () {
    late MockHttpClient retryClient;
    late AuthService retrySut;

    setUp(() {
      retryClient = MockHttpClient();
      retrySut = AuthService(
        httpClient: retryClient,
        retryDelays: const [Duration.zero, Duration.zero, Duration.zero],
      );
      registerFallbackValue(Uri());
    });

    test('retenta em 500 e retorna token na 2ª tentativa', () async {
      var calls = 0;
      when(() => retryClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async {
        calls++;
        return calls == 1
            ? http.Response('err', 500)
            : http.Response(
                jsonEncode({'access_token': 'jwt-token-123'}), 200);
      });

      final token = await retrySut.login('user@test.com', 'senha');

      expect(token, equals('jwt-token-123'));
      expect(calls, equals(2));
    });

    test('lança ApiException após esgotar tentativas em 500 persistente', () async {
      when(() => retryClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('err', 500));

      await expectLater(
        () => retrySut.login('user@test.com', 'senha'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 500)),
      );

      verify(() => retryClient.post(any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'))).called(4);
    });

    test('NÃO retenta em 401', () async {
      when(() => retryClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async =>
              http.Response('{"message":"Unauthorized"}', 401));

      await expectLater(
        () => retrySut.login('wrong@test.com', 'errada'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 401)),
      );

      verify(() => retryClient.post(any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'))).called(1);
    });
  });
}

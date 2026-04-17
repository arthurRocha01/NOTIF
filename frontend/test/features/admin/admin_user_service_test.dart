import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient mockClient;
  late AdminUserService service;

  const baseUrl = 'http://localhost:3000';
  const token = 'test-token';

  setUp(() {
    registerFallbackValue(FakeUri());
    mockClient = MockHttpClient();
    service = AdminUserService(httpClient: mockClient, baseUrl: baseUrl);
  });

  final userJson = {
    'id': 'user-1',
    'name': 'João Silva',
    'email': 'joao@test.com',
    'role': 'EMPLOYEE',
    'sectorId': 'sector-1',
  };

  // ---------------------------------------------------------------------------
  // getUsers
  // ---------------------------------------------------------------------------
  group('AdminUserService.getUsers', () {
    test('retorna lista de UserModel em sucesso', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async =>
              http.Response(jsonEncode([userJson]), 200));

      final result = await service.getUsers(token: token);

      expect(result, hasLength(1));
      expect(result.first.id, equals('user-1'));
      expect(result.first.name, equals('João Silva'));
      expect(result.first.role, equals(UserRole.employee));
    });

    test('chama GET /users com Authorization header', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        capturedHeaders =
            inv.namedArguments[const Symbol('headers')] as Map<String, String>;
        return http.Response(jsonEncode([]), 200);
      });

      await service.getUsers(token: token);

      expect(capturedUri?.path, equals('/users'));
      expect(capturedHeaders?.containsKey('Authorization'), isTrue);
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Erro', 500));

      await expectLater(
        () => service.getUsers(token: token),
        throwsA(isA<ApiException>()),
      );
    });

    test('lança ApiException em SocketException', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(const SocketException('no internet'));

      await expectLater(
        () => service.getUsers(token: token),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createUser
  // ---------------------------------------------------------------------------
  group('AdminUserService.createUser', () {
    test('chama POST /users e retorna UserModel', () async {
      Uri? capturedUri;
      String? capturedBody;

      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        capturedBody =
            inv.namedArguments[const Symbol('body')] as String;
        return http.Response(jsonEncode(userJson), 201);
      });

      final result = await service.createUser(
        token: token,
        name: 'João Silva',
        email: 'joao@test.com',
        password: 'senha123',
        role: 'EMPLOYEE',
        sectorId: 'sector-1',
      );

      expect(capturedUri?.path, equals('/users'));
      final body = jsonDecode(capturedBody!);
      expect(body['name'], equals('João Silva'));
      expect(body['email'], equals('joao@test.com'));
      expect(body['password'], equals('senha123'));
      expect(body['role'], equals('EMPLOYEE'));
      expect(body['sectorId'], equals('sector-1'));
      expect(body.containsKey('fcmToken'), isFalse);
      expect(result.id, equals('user-1'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.post(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Erro', 400));

      await expectLater(
        () => service.createUser(
          token: token,
          name: 'X',
          email: 'x@x.com',
          password: '123',
          role: 'EMPLOYEE',
          sectorId: 'sector-1',
        ),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateUser
  // ---------------------------------------------------------------------------
  group('AdminUserService.updateUser', () {
    test('chama PATCH /users/:id com os campos fornecidos', () async {
      Uri? capturedUri;
      String? capturedBody;

      when(() => mockClient.patch(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        capturedBody =
            inv.namedArguments[const Symbol('body')] as String;
        return http.Response(
            jsonEncode({...userJson, 'name': 'Novo Nome'}), 200);
      });

      final result = await service.updateUser(
        token: token,
        userId: 'user-1',
        name: 'Novo Nome',
      );

      expect(capturedUri?.path, endsWith('/users/user-1'));
      final body = jsonDecode(capturedBody!);
      expect(body['name'], equals('Novo Nome'));
      expect(result.id, equals('user-1'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.patch(any(),
              headers: any(named: 'headers'), body: any(named: 'body')))
          .thenAnswer((_) async => http.Response('Erro', 404));

      await expectLater(
        () => service.updateUser(token: token, userId: 'user-1'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // deleteUser
  // ---------------------------------------------------------------------------
  group('AdminUserService.deleteUser', () {
    test('chama DELETE /users/:id', () async {
      Uri? capturedUri;

      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((inv) async {
        capturedUri = inv.positionalArguments.first as Uri;
        return http.Response('', 200);
      });

      await service.deleteUser(token: token, userId: 'user-1');

      expect(capturedUri?.path, endsWith('/users/user-1'));
    });

    test('lança ApiException em erro HTTP', () async {
      when(() => mockClient.delete(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Erro', 404));

      await expectLater(
        () => service.deleteUser(token: token, userId: 'user-1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}

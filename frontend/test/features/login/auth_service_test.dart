import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _email = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late AuthService service;

  setUp(() {
    service = AuthService();
    ApiClient.clearToken();
  });

  group('AuthService.login', () {
    test('retorna token para credenciais válidas', () async {
      final token = await service.login(_email, _password);
      expect(token, isNotEmpty);
    });

    test('lança ApiException para credenciais inválidas', () async {
      await expectLater(
        service.login('invalid@notif.com', 'wrongpass'),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('AuthService.fetchUser', () {
    late String token;

    setUp(() async {
      token = await service.login(_email, _password);
      ApiClient.setToken(token);
    });

    test('retorna UserModel com sectorId preenchido', () async {
      final user = await service.fetchUser(_email);
      expect(user.sectorId, isNotEmpty);
      expect(user.sectorId, matches(
        RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'),
      ));
    });

    test('sectorName começa vazio antes de resolver', () async {
      final user = await service.fetchUser(_email);
      expect(user.sectorName, isEmpty);
    });

    test('retorna email e role corretos', () async {
      final user = await service.fetchUser(_email);
      expect(user.email, _email);
      expect(user.role.name, isNotEmpty);
    });
  });

  group('AuthService.updateFcmToken', () {
    test('atualiza token FCM sem erro', () async {
      final token = await service.login(_email, _password);
      ApiClient.setToken(token);
      final user = await service.fetchUser(_email);
      await expectLater(
        service.updateFcmToken(userId: user.id, fcmToken: 'test-device-token'),
        completes,
      );
    });
  });

  group('AuthService.updatePassword', () {
    test('atualiza senha com sucesso via PATCH /users/:id', () async {
      final token = await service.login(_email, _password);
      ApiClient.setToken(token);
      final user = await service.fetchUser(_email);
      await expectLater(
        service.updatePassword(userId: user.id, newPassword: _password),
        completes,
      );
    });

    test('permite login com senha recém-atualizada', () async {
      final token = await service.login(_email, _password);
      ApiClient.setToken(token);
      final user = await service.fetchUser(_email);
      await service.updatePassword(userId: user.id, newPassword: _password);
      ApiClient.clearToken();
      final newToken = await service.login(_email, _password);
      expect(newToken, isNotEmpty);
    });
  });
}

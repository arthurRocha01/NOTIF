import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _emailA = 'employee.dev@notif.com';
const _emailB = 'employee.ops@notif.com';
const _password = 'password123';

void main() {
  late AuthService service;
  late AlertService alertService;
  late String userAId;
  late String userBId;

  setUpAll(() async {
    service = AuthService();
    alertService = AlertService();

    final tokenA = await service.login(_emailA, _password);
    ApiClient.setToken(tokenA);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
    userAId = (await service.fetchUser(_emailA)).id;

    final tokenB = await service.login(_emailB, _password);
    ApiClient.setToken(tokenB);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }
    userBId = (await service.fetchUser(_emailB)).id;
  });

  setUp(() async {
    final token = await service.login(_emailA, _password);
    ApiClient.setToken(token);
  });

  group('updateFcmToken — comportamento básico', () {
    test('token é persistido no servidor após PATCH', () async {
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-basico');
      final user = await service.fetchUser(_emailA);
      expect(user.fcmToken, equals('token-basico'));
    });

    test('token novo sobrescreve o anterior', () async {
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-antigo');
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-novo');
      final user = await service.fetchUser(_emailA);
      expect(user.fcmToken, equals('token-novo'));
    });

    test('PATCH com mesmo token é idempotente', () async {
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-fixo');
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-fixo');
      final user = await service.fetchUser(_emailA);
      expect(user.fcmToken, equals('token-fixo'));
    });
  });

  group('updateFcmToken — isolamento entre usuários', () {
    test('token de A não afeta token de B', () async {
      final tokenB = await service.login(_emailB, _password);
      ApiClient.setToken(tokenB);
      await service.updateFcmToken(userId: userBId, fcmToken: 'token-b-inicial');

      final tokenA = await service.login(_emailA, _password);
      ApiClient.setToken(tokenA);
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-a');

      ApiClient.setToken(tokenB);
      final userB = await service.fetchUser(_emailB);
      expect(userB.fcmToken, equals('token-b-inicial'));
    });

    test('atualização de A não altera token de B', () async {
      final tokenB = await service.login(_emailB, _password);
      ApiClient.setToken(tokenB);
      await service.updateFcmToken(userId: userBId, fcmToken: 'token-b-estavel');

      final tokenA = await service.login(_emailA, _password);
      ApiClient.setToken(tokenA);
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-a-novo');
      await service.updateFcmToken(userId: userAId, fcmToken: 'token-a-atualizado');

      ApiClient.setToken(tokenB);
      final userB = await service.fetchUser(_emailB);
      expect(userB.fcmToken, equals('token-b-estavel'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _email = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late AuthService service;
  late String userId;

  setUpAll(() async {
    service = AuthService();
    final token = await service.login(_email, _password);
    ApiClient.setToken(token);
    final user = await service.fetchUser(_email);
    userId = user.id;
  });

  setUp(() async {
    final token = await service.login(_email, _password);
    ApiClient.setToken(token);
  });

  group('Cenário: primeiro dispositivo — token inicialmente ausente', () {
    test('usuário sem token aceita PATCH com token novo', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-primeiro-dispositivo');
      final user = await service.fetchUser(_email);
      expect(user.fcmToken, equals('token-primeiro-dispositivo'));
    });

    test('fetchUser reflete o token após primeira sincronização', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-sync-inicial');
      final user = await service.fetchUser(_email);
      expect(user.fcmToken, isNotNull);
      expect(user.fcmToken, isNotEmpty);
    });
  });

  group('Cenário: troca de dispositivo', () {
    test('token do novo dispositivo sobrescreve o anterior no servidor', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-dispositivo-A');
      final antes = await service.fetchUser(_email);
      expect(antes.fcmToken, equals('token-dispositivo-A'));

      await service.updateFcmToken(userId: userId, fcmToken: 'token-dispositivo-B');
      final depois = await service.fetchUser(_email);
      expect(depois.fcmToken, equals('token-dispositivo-B'));
      expect(depois.fcmToken, isNot(equals(antes.fcmToken)));
    });

    test('servidor mantém apenas o token mais recente', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-antigo');
      await service.updateFcmToken(userId: userId, fcmToken: 'token-novo');

      final user = await service.fetchUser(_email);
      expect(user.fcmToken, equals('token-novo'));
    });
  });

  group('Cenário: expiração / rotação do token pelo Firebase', () {
    test('token rotacionado é persistido no servidor', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'fcm-original');
      await service.updateFcmToken(userId: userId, fcmToken: 'fcm-rotacionado');

      final user = await service.fetchUser(_email);
      expect(user.fcmToken, equals('fcm-rotacionado'));
    });

    test('fetchUser após rotação não retorna mais o token expirado', () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-expirado');
      await service.updateFcmToken(userId: userId, fcmToken: 'token-pos-rotacao');

      final user = await service.fetchUser(_email);
      expect(user.fcmToken, isNot(equals('token-expirado')));
    });
  });

  group('Mecanismo de auto-cura', () {
    test('divergência entre token do dispositivo e do servidor é detectável via fetchUser',
        () async {
      await service.updateFcmToken(userId: userId, fcmToken: 'token-servidor-desatualizado');
      final userServidor = await service.fetchUser(_email);

      const tokenDispositivo = 'token-dispositivo-novo';
      expect(userServidor.fcmToken, isNot(equals(tokenDispositivo)),
          reason: 'divergência deve ser detectável para o sync ser acionado');

      await service.updateFcmToken(userId: userId, fcmToken: tokenDispositivo);
      final userSincronizado = await service.fetchUser(_email);
      expect(userSincronizado.fcmToken, equals(tokenDispositivo));
    });

    test('PATCH com o mesmo token não quebra o estado do servidor', () async {
      const token = 'token-sem-mudanca';
      await service.updateFcmToken(userId: userId, fcmToken: token);
      await service.updateFcmToken(userId: userId, fcmToken: token);

      final user = await service.fetchUser(_email);
      expect(user.fcmToken, equals(token));
    });
  });
}

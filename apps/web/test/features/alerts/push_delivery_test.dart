import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String employeeSectorId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    await loginAsEmployee(authService);
    employeeSectorId = (await authService.fetchProfile()).sectorId;
  });

  group('Push delivery — token real (app rodando no Chrome)', () {
    test('notificação chega no app quando token real está registrado', () async {
      final empToken = await loginAsEmployee(authService);
      final employeeAntes = await authService.fetchProfile();
      final fcmToken = employeeAntes.fcmToken;

      if (fcmToken == null || fcmToken == kFakeToken) {
        markTestSkipped(
          'Pré-condição não atendida: rode o app com "flutter run -d chrome", '
          'faça login como ${kEmployeeEmail} e aceite a permissão de notificação. '
          'O token FCM real será registrado automaticamente.',
        );
        return;
      }

      final tokenAntes = fcmToken;

      await loginAsSupervisor(authService);

      await alertService.createNotification(
        title: 'Teste de Push Real',
        message: 'Se você está vendo esta notificação no Chrome, o fluxo funciona.',
        level: AlertLevel.high,
        slaMinutes: 15,
        requiresAcknowledgment: true,
        sectorId: employeeSectorId,
      );

      ApiClient.setToken(empToken);
      final employeeDepois = await authService.fetchProfile();
      expect(
        employeeDepois.fcmToken,
        equals(tokenAntes),
        reason:
            'Token foi zerado: Firebase rejeitou o token. '
            'Verifique se o app está rodando e com permissão de notificação ativa.',
      );
    });
  });

  group('Push delivery — token inválido (sem app rodando)', () {
    test(
        'fcmToken é zerado após criação de notificação com token inválido registrado',
        () async {
      final empToken = await loginAsEmployee(authService);
      await authService.updateFcmToken(kFakeToken);

      final antes = await authService.fetchProfile();
      expect(antes.fcmToken, equals(kFakeToken),
          reason: 'pré-condição: token falso deve estar salvo no servidor');

      await loginAsSupervisor(authService);

      await alertService.createNotification(
        title: 'Push Delivery Test',
        message: 'Notificação para validar o envio FCM de ponta a ponta.',
        level: AlertLevel.low,
        slaMinutes: 30,
        requiresAcknowledgment: false,
        sectorId: employeeSectorId,
      );

      ApiClient.setToken(empToken);
      final depois = await authService.fetchProfile();
      expect(depois.fcmToken, isNull,
          reason:
              'Firebase rejeitou o token inválido; backend deve ter zerado fcmToken');
    });
  });
}

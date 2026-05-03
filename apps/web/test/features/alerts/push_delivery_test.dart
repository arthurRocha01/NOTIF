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

    await loginAs(authService, kAdminEmail);

    final employee = await authService.fetchUser(kEmployeeEmail);
    employeeSectorId = employee.sectorId;
  });

  group('Push delivery — token real (app rodando no Chrome)', () {
    // Pré-condição: rode o app com `flutter run -d chrome`, faça login como
    // employee.dev@notif.com e aceite a permissão de notificação.
    // O app registra o token FCM real no backend automaticamente.
    // Ao rodar este teste, a notificação deve aparecer no Chrome.
    test('notificação chega no app quando token real está registrado', skip: 'requer app rodando no Chrome com employee logado e permissão FCM concedida', () async {
      final empToken = await loginAsEmployee(authService);

      final employeeAntes = await authService.fetchUser(kEmployeeEmail);
      expect(
        employeeAntes.fcmToken,
        isNotNull,
        reason:
            'Pré-condição falhou: rode o app em flutter run -d chrome, '
            'faça login como employee e aceite a permissão de notificação.',
      );

      final tokenAntes = employeeAntes.fcmToken!;

      await loginAs(authService, kAdminEmail);

      await alertService.createNotification(
        title: 'Teste de Push Real',
        message: 'Se você está vendo esta notificação no Chrome, o fluxo funciona.',
        level: AlertLevel.high,
        slaMinutes: 15,
        requiresAcknowledgment: true,
        sectorId: employeeSectorId,
      );

      ApiClient.setToken(empToken);
      final employeeDepois = await authService.fetchUser(kEmployeeEmail);
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
        skip: 'requer Firebase real — token inválido só é detectado quando FCM tenta entregar',
        () async {
      final empToken = await loginAsEmployee(authService);
      await authService.updateFcmToken(
        userId: (await authService.fetchUser(kEmployeeEmail)).id,
        fcmToken: kFakeToken,
      );

      final antes = await authService.fetchUser(kEmployeeEmail);
      expect(antes.fcmToken, equals(kFakeToken),
          reason: 'pré-condição: token falso deve estar salvo no servidor');

      await loginAs(authService, kAdminEmail);

      await alertService.createNotification(
        title: 'Push Delivery Test',
        message: 'Notificação para validar o envio FCM de ponta a ponta.',
        level: AlertLevel.low,
        slaMinutes: 30,
        requiresAcknowledgment: false,
        sectorId: employeeSectorId,
      );

      ApiClient.setToken(empToken);
      final depois = await authService.fetchUser(kEmployeeEmail);
      expect(depois.fcmToken, isNull,
          reason:
              'Firebase rejeitou o token inválido; backend deve ter zerado fcmToken');
    });
  });
}

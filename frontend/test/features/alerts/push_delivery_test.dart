import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _employeeEmail = 'employee.dev@notif.com';
const _password = 'password123';

// Qualquer string que não seja um token FCM real é rejeitada pelo Firebase,
// o que faz o backend zerar o campo fcmToken no banco — evidência de que o
// fluxo de push foi percorrido de ponta a ponta.
const _fakeToken = 'fcm-invalido-push-test';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String adminId;
  late String employeeId;
  late String employeeSectorId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final adminToken = await authService.login(_adminEmail, _password);
    ApiClient.setToken(adminToken);

    final admin = await authService.fetchUser(_adminEmail);
    adminId = admin.id;

    final employee = await authService.fetchUser(_employeeEmail);
    employeeId = employee.id;
    employeeSectorId = employee.sectorId;
  });

  group('Push delivery — token real (app rodando no Chrome)', () {
    // Pré-condição: rode o app com `flutter run -d chrome`, faça login como
    // employee.dev@notif.com e aceite a permissão de notificação.
    // O app registra o token FCM real no backend automaticamente.
    // Ao rodar este teste, a notificação deve aparecer no Chrome.
    test('notificação chega no app quando token real está registrado', () async {
      // Verifica pré-condição: employee deve ter um token real registrado
      final empToken = await authService.login(_employeeEmail, _password);
      ApiClient.setToken(empToken);

      final employeeAntes = await authService.fetchUser(_employeeEmail);
      expect(
        employeeAntes.fcmToken,
        isNotNull,
        reason:
            'Pré-condição falhou: rode o app em flutter run -d chrome, '
            'faça login como employee e aceite a permissão de notificação.',
      );

      final tokenAntes = employeeAntes.fcmToken!;

      // Admin cria a notificação — o push deve chegar no Chrome agora
      final adminToken = await authService.login(_adminEmail, _password);
      ApiClient.setToken(adminToken);

      await alertService.createNotification(
        authorId: adminId,
        title: 'Teste de Push Real',
        message: 'Se você está vendo esta notificação no Chrome, o fluxo funciona.',
        level: AlertLevel.high,
        slaMinutes: 15,
        requiresAcknowledgment: true,
        sectorId: employeeSectorId,
      );

      // Token permanece inalterado → Firebase aceitou → push foi entregue
      final empToken2 = await authService.login(_employeeEmail, _password);
      ApiClient.setToken(empToken2);

      final employeeDepois = await authService.fetchUser(_employeeEmail);
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
      // 1. Employee registra um token falso
      final empToken = await authService.login(_employeeEmail, _password);
      ApiClient.setToken(empToken);
      await authService.updateFcmToken(
        userId: employeeId,
        fcmToken: _fakeToken,
      );

      final antes = await authService.fetchUser(_employeeEmail);
      expect(antes.fcmToken, equals(_fakeToken),
          reason: 'pré-condição: token falso deve estar salvo no servidor');

      // 2. Admin cria notificação para o setor do employee
      //    O backend chama Firebase → Firebase rejeita o token falso →
      //    backend remove o token do usuário
      final adminToken = await authService.login(_adminEmail, _password);
      ApiClient.setToken(adminToken);

      await alertService.createNotification(
        authorId: adminId,
        title: 'Push Delivery Test',
        message: 'Notificação para validar o envio FCM de ponta a ponta.',
        level: AlertLevel.low,
        slaMinutes: 30,
        requiresAcknowledgment: false,
        sectorId: employeeSectorId,
      );

      // 3. Token deve ter sido zerado — prova que Firebase foi chamado e rejeitou
      final empToken2 = await authService.login(_employeeEmail, _password);
      ApiClient.setToken(empToken2);

      final depois = await authService.fetchUser(_employeeEmail);
      expect(depois.fcmToken, isNull,
          reason:
              'Firebase rejeitou o token inválido; backend deve ter zerado fcmToken');
    });
  });
}

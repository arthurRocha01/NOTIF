import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

// Pré-condição: estar logado no app como employee.dev@notif.com no Chrome
// com permissão de notificação concedida.
//
// Rodar: flutter test test/features/alerts/fcm_trigger_test.dart

const _supervisorEmail = 'supervisor.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final token = await authService.login(_supervisorEmail, _password);
    ApiClient.setToken(token);
  });

  test('dispara FCM para employee.dev (setor TI)', () async {
    await alertService.createNotification(
      title: 'Teste FCM — Você recebeu!',
      message: 'Se esta notificação apareceu no Chrome, o FCM está funcionando.',
      level: AlertLevel.high,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: null, // global — garante que employee.dev recebe mesmo sem sectorId em mãos
    );

    // Sem assert: o objetivo é visual — ver a notificação chegar no Chrome.
    // Se o teste passar sem exception, a API aceitou e o FCM foi acionado.
  });
}

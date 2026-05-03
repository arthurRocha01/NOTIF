import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

// Pré-condição: estar logado no app como employee.dev@notif.com no Chrome
// com permissão de notificação concedida.
//
// Rodar: flutter test test/features/alerts/fcm_trigger_test.dart

void main() {
  late AlertService alertService;
  late AuthService authService;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    await loginAsSupervisor(authService);
  });

  test('dispara FCM para employee.dev (setor TI)', () async {
    await alertService.createNotification(
      title: 'Teste FCM — Você recebeu!',
      message: 'Se esta notificação apareceu no Chrome, o FCM está funcionando.',
      level: AlertLevel.high,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: null,
    );

    // Sem assert: o objetivo é visual — ver a notificação chegar no Chrome.
    // Se o teste passar sem exception, a API aceitou e o FCM foi acionado.
  });
}

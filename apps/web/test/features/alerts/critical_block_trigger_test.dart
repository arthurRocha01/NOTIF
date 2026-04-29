import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

// Pré-condição: estar logado no app como employee.dev@notif.com no Chrome.
//
// Ao rodar este teste, o app deve:
//   1. Tocar o som de alerta
//   2. Exibir a tela de bloqueio crítico (CriticalAlertOverlay)
//   3. Impedir navegação até o employee confirmar ciência
//
// Rodar: flutter test test/features/alerts/critical_block_trigger_test.dart

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

  test('dispara alerta CRÍTICO para employee.dev e exibe tela de bloqueio', () async {
    await alertService.createNotification(
      title: '🚨 Alerta Crítico — Teste de Bloqueio',
      message: 'Este é um teste do sistema de bloqueio crítico. Confirme a ciência para desbloquear o app.',
      level: AlertLevel.critical,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: null, // global
    );
  });
}

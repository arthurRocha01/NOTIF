import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String assignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await loginAsSupervisor(authService);
    await clearBlocking(alertService);
    await loginAsEmployee(authService);
    await clearBlocking(alertService);

    final employee = await authService.fetchProfile();
    ApiClient.setToken(supervisorToken);

    final notif = await alertService.createNotification(
      title: 'CRITICAL SLA Negligência TDD',
      message: 'Alerta crítico que não será confirmado — testa desbloqueio por vencimento do SLA.',
      level: AlertLevel.critical,
      slaMinutes: 1,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final blocking = await alertService.getBlockingAssignments();
    assignmentId = blocking.firstWhere((a) => a.notificationId == notif.id).id;

    // Aguarda o SLA vencer e o cron executar sem que o employee confirme
    await Future.delayed(const Duration(seconds: 120));
  });

  setUp(() async {
    await loginAsEmployee(authService);
  });

  group('CRITICAL não confirmado dentro do SLA — desbloqueio por negligência', () {
    test('assignment vira OVERDUE após vencimento do SLA', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.overdue),
          reason: 'assignment CRITICAL não confirmado deveria ser OVERDUE após slaMinutes=1');
    });

    test('assignment OVERDUE não aparece em getBlockingAssignments e libera o employee', () async {
      final blocking = await alertService.getBlockingAssignments();
      expect(blocking.any((a) => a.id == assignmentId), isFalse,
          reason: 'OVERDUE não deve bloquear — bloqueio serve para forçar ciência, não punir');

      final notifications = await alertService.getNotifications();
      expect(notifications, isA<List>());
    });
  });
}

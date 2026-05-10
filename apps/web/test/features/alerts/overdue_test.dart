import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String employeeAssignmentId;
  late String undeliveredAssignmentId;

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
      title: 'Notificação SLA Overdue TDD',
      message: 'Criada para testar a transição automática para OVERDUE após vencimento do SLA.',
      level: AlertLevel.medium,
      slaMinutes: 1,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final empAssignments = await alertService.getMyAssignments();
    employeeAssignmentId = empAssignments
        .firstWhere((a) => a.notificationId == notif.id)
        .id;

    await loginAs(authService, kEmployeeOpsEmail);
    final opsEmployee = await authService.fetchProfile();
    ApiClient.setToken(supervisorToken);
    final notif2 = await alertService.createNotification(
      title: 'Notificação Sem Sync TDD',
      message: 'Criada para validar que assignment sem deliveredAt não vira OVERDUE.',
      level: AlertLevel.medium,
      slaMinutes: 1,
      requiresAcknowledgment: true,
      sectorId: opsEmployee.sectorId,
    );

    await loginAs(authService, kEmployeeOpsEmail);
    final empAssignments2 = await alertService.getMyAssignments();
    undeliveredAssignmentId = empAssignments2
        .firstWhere((a) => a.notificationId == notif2.id)
        .id;

    // Aguarda o SLA vencer e o cron executar (pior caso: 119s após sync)
    await Future.delayed(const Duration(seconds: 120));
  });

  setUp(() async {
    await loginAsEmployee(authService);
  });

  group('Transição automática para OVERDUE', () {
    test('assignment PENDING com SLA vencido vira OVERDUE', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == employeeAssignmentId);
      expect(a.status, equals(AssignmentStatus.overdue),
          reason: 'assignment deveria ser OVERDUE após 120s com slaMinutes=1');
    });

    test('assignment sem deliveredAt permanece PENDING', () async {
      await loginAs(authService, kEmployeeOpsEmail);
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == undeliveredAssignmentId);
      expect(a.status, equals(AssignmentStatus.pending),
          reason: 'sem sync não há dueAt, portanto não pode ser OVERDUE');
    });
  });
}

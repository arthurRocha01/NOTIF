import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String notificationId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await loginAsSupervisor(authService);
    await clearBlocking(alertService);

    for (final email in [kEmployeeEmail, kEmployeeOpsEmail]) {
      await loginAs(authService, email);
      await clearBlocking(alertService);
    }

    ApiClient.setToken(supervisorToken);

    final tiEmployee = await authService.fetchUser(kEmployeeEmail);

    final notification = await alertService.createNotification(
      title: 'Notificação Setorial TDD',
      message: 'Direcionada apenas ao setor TI — Ops não deve receber.',
      level: AlertLevel.low,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      sectorId: tiEmployee.sectorId,
    );

    notificationId = notification.id;
  });

  group('Isolamento setorial — notificação direcionada a um setor', () {
    test('employee do setor alvo recebe o assignment', () async {
      await loginAs(authService, kEmployeeEmail);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isNotEmpty,
          reason: 'employee TI não recebeu a notificação setorial dirigida ao seu setor');
    });

    test('employee de outro setor não recebe o assignment', () async {
      await loginAs(authService, kEmployeeOpsEmail);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isEmpty,
          reason: 'employee Ops recebeu notificação direcionada ao setor TI');
    });

    test('getAllAssignments não contém userId do employee de outro setor', () async {
      await loginAsSupervisor(authService);

      final all = await alertService.getAllAssignments();
      final forNotification = all.where((a) => a.notificationId == notificationId).toList();
      final userIds = forNotification.map((a) => a.userId).toSet();

      final opsUser = await authService.fetchUser(kEmployeeOpsEmail);

      expect(userIds, isNot(contains(opsUser.id)),
          reason: 'userId do employee Ops está nos assignments da notificação setorial TI');
    });
  });
}

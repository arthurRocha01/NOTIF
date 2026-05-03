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

    final notification = await alertService.createNotification(
      title: 'Aviso Global TDD',
      message: 'Notificação global criada para validar assignments em todos os setores.',
      level: AlertLevel.low,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      sectorId: null,
    );

    notificationId = notification.id;
  });

  group('Notificação global — assignments criados para todos os setores', () {
    test('employee do setor TI recebe assignment', () async {
      await loginAs(authService, kEmployeeEmail);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isNotEmpty,
          reason: 'employee TI não recebeu assignment da notificação global');
    });

    test('employee do setor Operações recebe assignment', () async {
      await loginAs(authService, kEmployeeOpsEmail);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isNotEmpty,
          reason: 'employee Ops não recebeu assignment da notificação global');
    });

    test('assignments gerados têm status PENDING', () async {
      for (final email in [kEmployeeEmail, kEmployeeOpsEmail]) {
        await loginAs(authService, email);

        final assignments = await alertService.getMyAssignments();
        final match = assignments.firstWhere((a) => a.notificationId == notificationId);

        expect(match.status, equals(AssignmentStatus.pending),
            reason: 'assignment de $email não está PENDING');
      }
    });

    test('assignment da notificação global tem notificationTitle preenchido', () async {
      await loginAs(authService, kEmployeeEmail);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.firstWhere((a) => a.notificationId == notificationId);

      expect(match.notificationTitle, isNotNull);
      expect(match.notificationTitle, isNotEmpty);
    });

    test('getAllAssignments contém assignments dos dois setores para a notificação global',
        () async {
      await loginAsSupervisor(authService);

      final all = await alertService.getAllAssignments();
      final forNotification =
          all.where((a) => a.notificationId == notificationId).toList();

      final userIds = forNotification.map((a) => a.userId).toSet();

      final tiUser = await authService.fetchUser(kEmployeeEmail);
      final opsUser = await authService.fetchUser(kEmployeeOpsEmail);

      expect(userIds, contains(tiUser.id),
          reason: 'userId do employee TI não está entre os assignments globais');
      expect(userIds, contains(opsUser.id),
          reason: 'userId do employee Ops não está entre os assignments globais');
    });
  });
}

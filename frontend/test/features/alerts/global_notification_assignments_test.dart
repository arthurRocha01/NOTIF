import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _employeeTiEmail = 'employee.dev@notif.com';
const _employeeOpsEmail = 'employee.ops@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String notificationId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final adminToken = await authService.login(_adminEmail, _password);
    ApiClient.setToken(adminToken);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    for (final email in [_employeeTiEmail, _employeeOpsEmail]) {
      final t = await authService.login(email, _password);
      ApiClient.setToken(t);
      for (final a in await alertService.getBlockingAssignments()) {
        await alertService.acknowledge(a.id);
      }
    }

    ApiClient.setToken(adminToken);
    final admin = await authService.fetchUser(_adminEmail);

    final notification = await alertService.createNotification(
      authorId: admin.id,
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
      final token = await authService.login(_employeeTiEmail, _password);
      ApiClient.setToken(token);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isNotEmpty,
          reason: 'employee TI não recebeu assignment da notificação global');
    });

    test('employee do setor Operações recebe assignment', () async {
      final token = await authService.login(_employeeOpsEmail, _password);
      ApiClient.setToken(token);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.where((a) => a.notificationId == notificationId);

      expect(match, isNotEmpty,
          reason: 'employee Ops não recebeu assignment da notificação global');
    });

    test('assignments gerados têm status PENDING', () async {
      final users = [_employeeTiEmail, _employeeOpsEmail];

      for (final email in users) {
        final token = await authService.login(email, _password);
        ApiClient.setToken(token);

        final assignments = await alertService.getMyAssignments();
        final match = assignments.firstWhere((a) => a.notificationId == notificationId);

        expect(match.status, equals(AssignmentStatus.pending),
            reason: 'assignment de $email não está PENDING');
      }
    });

    test('assignment da notificação global tem notificationTitle preenchido', () async {
      final token = await authService.login(_employeeTiEmail, _password);
      ApiClient.setToken(token);

      final assignments = await alertService.getMyAssignments();
      final match = assignments.firstWhere((a) => a.notificationId == notificationId);

      expect(match.notificationTitle, isNotNull);
      expect(match.notificationTitle, isNotEmpty);
    });

    test('getAllAssignments contém assignments dos dois setores para a notificação global',
        () async {
      final adminToken = await authService.login(_adminEmail, _password);
      ApiClient.setToken(adminToken);

      final all = await alertService.getAllAssignments();
      final forNotification =
          all.where((a) => a.notificationId == notificationId).toList();

      final userIds = forNotification.map((a) => a.userId).toSet();

      final tiUser = await authService.fetchUser(_employeeTiEmail);
      final opsUser = await authService.fetchUser(_employeeOpsEmail);

      expect(userIds, contains(tiUser.id),
          reason: 'userId do employee TI não está entre os assignments globais');
      expect(userIds, contains(opsUser.id),
          reason: 'userId do employee Ops não está entre os assignments globais');
    });
  });
}

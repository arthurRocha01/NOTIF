import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/models/my_assignment_model.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late MyAssignmentModel assignment;
  late MyAssignmentModel pendingAssignment;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await loginAsSupervisor(authService);
    await clearBlocking(alertService);
    await loginAsEmployee(authService);
    await clearBlocking(alertService);

    final employee = await authService.fetchProfile();
    ApiClient.setToken(supervisorToken);

    final conflictNotif = await alertService.createNotification(
      title: 'Conflito Teste TDD',
      message: 'Notificação criada para testar erros de transição de estado.',
      level: AlertLevel.low,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    final pendingNotif = await alertService.createNotification(
      title: 'Acknowledge sem View TDD',
      message: 'Notificação para testar que acknowledge exige markAsViewed primeiro.',
      level: AlertLevel.low,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final assignments = await alertService.getMyAssignments();
    assignment = assignments.firstWhere(
      (a) => a.notificationId == conflictNotif.id,
    );
    pendingAssignment = assignments.firstWhere(
      (a) => a.notificationId == pendingNotif.id,
    );
  });

  setUp(() async {
    await loginAsEmployee(authService);
  });

  group('markAsViewed — conflitos de estado', () {
    test('lança ApiException ao tentar visualizar assignment já VIEWED',
        () async {
      await alertService.markAsViewed(assignment.id);

      await expectLater(
        alertService.markAsViewed(assignment.id),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('visualizada'),
          ),
        ),
      );
    });

    test('lança ApiException ao tentar visualizar assignment já ACKNOWLEDGED',
        () async {
      await alertService.acknowledge(assignment.id);

      await expectLater(
        alertService.markAsViewed(assignment.id),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('confirmada'),
          ),
        ),
      );
    });
  });

  group('acknowledge — conflitos de estado', () {
    test('lança ApiException ao tentar confirmar assignment já ACKNOWLEDGED',
        () async {
      await expectLater(
        alertService.acknowledge(assignment.id),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('confirmada'),
          ),
        ),
      );
    });

    test('lança 409 ao tentar confirmar assignment PENDING sem ter visualizado',
        () async {
      await expectLater(
        alertService.acknowledge(pendingAssignment.id),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409),
        ),
      );
    });
  });
}

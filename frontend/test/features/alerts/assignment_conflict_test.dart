import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _supervisorEmail = 'supervisor.dev@notif.com';
const _employeeEmail = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String employeeId;
  late String employeeSectorId;
  late AssignmentModel assignment;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await authService.login(_supervisorEmail, _password);
    ApiClient.setToken(supervisorToken);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    final empTokenPre = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(empTokenPre);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    // busca o setor do employee para criar notificação direcionada
    ApiClient.setToken(supervisorToken);
    final employee = await authService.fetchUser(_employeeEmail);
    employeeId = employee.id;
    employeeSectorId = employee.sectorId;

    // cria notificação setorial → gera assignment para o employee
    await alertService.createNotification(
      title: 'Conflito Teste TDD',
      message: 'Notificação criada para testar erros de transição de estado.',
      level: AlertLevel.low,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employeeSectorId,
    );

    // loga como employee e sincroniza entregas
    final employeeToken = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(employeeToken);
    await alertService.syncDeliveries();

    // busca o assignment recém-criado
    final assignments = await alertService.getMyAssignments();
    assignment = assignments.firstWhere(
      (a) => a.status == AssignmentStatus.pending,
    );
  });

  setUp(() async {
    final token = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(token);
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
  });
}

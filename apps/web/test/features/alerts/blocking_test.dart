import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
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
  late String assignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    // Limpa bloqueios pré-existentes do supervisor
    final supervisorToken = await authService.login(_supervisorEmail, _password);
    ApiClient.setToken(supervisorToken);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    // Limpa bloqueios pré-existentes do employee
    final empTokenPre = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(empTokenPre);
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

    // Setup: cria a notificação CRITICAL do teste (supervisor não recebe assignment próprio)
    ApiClient.setToken(supervisorToken);
    final employee = await authService.fetchUser(_employeeEmail);
    employeeId = employee.id;

    await alertService.createNotification(
      title: 'Bloqueio Crítico TDD',
      message: 'Notificação crítica para testar o bloqueio sistêmico do colaborador.',
      level: AlertLevel.critical,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    // Captura o assignmentId do employee
    final employeeToken = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(employeeToken);

    final blocking = await alertService.getBlockingAssignments();
    assignmentId = blocking.first.id;
  });

  setUp(() async {
    final token = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(token);
  });

  group('Bloqueio sistêmico — CRITICAL não confirmado', () {
    test('getBlockingAssignments retorna o assignment CRITICAL pendente', () async {
      final blocking = await alertService.getBlockingAssignments();

      expect(blocking, isNotEmpty);
      expect(blocking.any((a) => a.id == assignmentId), isTrue);
      expect(
        blocking.every((a) => a.notificationLevel == AlertLevel.critical),
        isTrue,
      );
      expect(
        blocking.every((a) => a.status != AssignmentStatus.acknowledged),
        isTrue,
      );
    });

    test('GET /notifications retorna 403 enquanto há CRITICAL não confirmado', () async {
      await expectLater(
        alertService.getNotifications(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('GET /assignments/mine funciona enquanto bloqueado', () async {
      final assignments = await alertService.getMyAssignments();
      expect(assignments, isA<List>());
    });

    test('GET /assignments/blocking funciona enquanto bloqueado', () async {
      final blocking = await alertService.getBlockingAssignments();
      expect(blocking, isNotEmpty);
    });

    test('POST /assignments/:id/acknowledge funciona enquanto bloqueado', () async {
      await expectLater(
        alertService.acknowledge(assignmentId),
        completes,
      );
    });

    test('getBlockingAssignments retorna lista vazia após acknowledge', () async {
      final blocking = await alertService.getBlockingAssignments();
      expect(blocking.any((a) => a.id == assignmentId), isFalse);
    });

    test('GET /notifications volta a funcionar após desbloqueio', () async {
      final notifications = await alertService.getNotifications();
      expect(notifications, isA<List>());
    });
  });
}

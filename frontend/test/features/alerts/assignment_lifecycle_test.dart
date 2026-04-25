import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _employeeEmail = 'employee.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String employeeId;
  late String employeeSectorId;
  late String assignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final adminToken = await authService.login(_adminEmail, _password);
    ApiClient.setToken(adminToken);

    final admin = await authService.fetchUser(_adminEmail);
    final employee = await authService.fetchUser(_employeeEmail);
    employeeId = employee.id;
    employeeSectorId = employee.sectorId;

    await alertService.createNotification(
      authorId: admin.id,
      title: 'Ciclo de Vida TDD',
      message: 'Notificação criada para testar o ciclo PENDING → VIEWED → ACKNOWLEDGED.',
      level: AlertLevel.medium,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employeeSectorId,
    );

    final employeeToken = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(employeeToken);
    await alertService.syncDeliveries(employeeId);

    final assignments = await alertService.getMyAssignments();
    final pending = assignments.where((a) => a.status == AssignmentStatus.pending).toList();
    assignmentId = pending.first.id;
  });

  setUp(() async {
    final token = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(token);
  });

  group('Ciclo de vida do assignment — caminho feliz', () {
    test('assignment recém-sincronizado está com status PENDING', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.pending));
    });

    test('syncDeliveries preenche deliveredAt', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.deliveredAt, isNotNull);
    });

    test('markAsViewed transiciona status para VIEWED', () async {
      await alertService.markAsViewed(assignmentId);

      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.viewed));
    });

    test('markAsViewed preenche viewedAt', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.viewedAt, isNotNull);
    });

    test('acknowledge transiciona status para ACKNOWLEDGED', () async {
      await alertService.acknowledge(assignmentId);

      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.acknowledged));
    });

    test('acknowledge preenche acknowledgedAt', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.acknowledgedAt, isNotNull);
    });

    test('acknowledgedAt é posterior a deliveredAt', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.acknowledgedAt!.isAfter(a.deliveredAt!), isTrue);
    });
  });
}

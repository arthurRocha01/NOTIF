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

    ApiClient.setToken(supervisorToken);
    final employee = await authService.fetchUser(kEmployeeEmail);

    await alertService.createNotification(
      title: 'Ciclo de Vida TDD',
      message: 'Notificação criada para testar o ciclo PENDING → VIEWED → ACKNOWLEDGED.',
      level: AlertLevel.medium,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final assignments = await alertService.getMyAssignments();
    assignmentId = assignments
        .firstWhere((a) => a.status == AssignmentStatus.pending)
        .id;
  });

  setUp(() async {
    await loginAsEmployee(authService);
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

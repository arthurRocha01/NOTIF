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
    test('assignment recém-sincronizado está PENDING com deliveredAt preenchido', () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.pending));
      expect(a.deliveredAt, isNotNull);
    });

    test('markAsViewed transiciona para VIEWED e preenche viewedAt', () async {
      await alertService.markAsViewed(assignmentId);

      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.viewed));
      expect(a.viewedAt, isNotNull);
    });

    test('acknowledge transiciona para ACKNOWLEDGED e acknowledgedAt é posterior a deliveredAt', () async {
      await alertService.acknowledge(assignmentId);

      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == assignmentId);
      expect(a.status, equals(AssignmentStatus.acknowledged));
      expect(a.acknowledgedAt, isNotNull);
      expect(a.acknowledgedAt!.isAfter(a.deliveredAt!), isTrue);
    });
  });
}

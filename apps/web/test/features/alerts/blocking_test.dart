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
  late String pendingAssignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await loginAsSupervisor(authService);
    await clearBlocking(alertService);
    await loginAsEmployee(authService);
    await clearBlocking(alertService);

    final employee = await authService.fetchProfile();
    ApiClient.setToken(supervisorToken);

    final criticalNotif = await alertService.createNotification(
      title: 'Bloqueio Crítico TDD',
      message: 'Notificação crítica para testar o bloqueio sistêmico do colaborador.',
      level: AlertLevel.critical,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    final pendingNotif = await alertService.createNotification(
      title: 'Pendente Sem Bloqueio TDD',
      message: 'Notificação não crítica com ciência exigida — não deve bloquear.',
      level: AlertLevel.medium,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final blocking = await alertService.getBlockingAssignments();
    assignmentId = blocking.firstWhere((a) => a.notificationId == criticalNotif.id).id;

    final all = await alertService.getMyAssignments();
    pendingAssignmentId = all
        .firstWhere((a) => a.notificationId == pendingNotif.id)
        .id;
  });

  setUp(() async {
    await loginAsEmployee(authService);
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

  group('Sem bloqueio — PENDING com ciência exigida mas não crítico', () {
    test('assignment não crítico com requiresAcknowledgment não aparece em getBlockingAssignments',
        () async {
      final blocking = await alertService.getBlockingAssignments();
      expect(blocking.any((a) => a.id == pendingAssignmentId), isFalse,
          reason: 'apenas CRITICAL deve bloquear — MEDIUM com requiresAcknowledgment não bloqueia');
    });

    test('assignment não crítico com requiresAcknowledgment fica como PENDING',
        () async {
      final assignments = await alertService.getMyAssignments();
      final a = assignments.firstWhere((a) => a.id == pendingAssignmentId);
      expect(a.status, equals(AssignmentStatus.pending));
    });
  });
}

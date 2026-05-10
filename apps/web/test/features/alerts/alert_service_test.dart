import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  setUp(() async {
    alertService = AlertService();
    authService = AuthService();
    ApiClient.clearToken();

    await loginAsEmployee(authService);
    await clearBlocking(alertService);
  });

  group('AlertService.getMyAssignments — campos enriquecidos do DTO', () {
    test('notificationTitle e notificationRequiresAcknowledgment estão preenchidos', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationTitle, isNotNull,
            reason: 'notificationTitle veio null para assignment ${a.id}');
        expect(a.notificationTitle, isNotEmpty,
            reason: 'notificationTitle veio vazio para assignment ${a.id}');
        expect(a.notificationRequiresAcknowledgment, isNotNull,
            reason: 'notificationRequiresAcknowledgment veio null para assignment ${a.id}');
      }
    });
  });

  group('AlertService.syncDeliveries', () {
    test('é idempotente — segunda chamada completa sem erro', () async {
      await alertService.syncDeliveries();
      await expectLater(alertService.syncDeliveries(), completes);
    });

    test('assignments têm deliveredAt preenchido após sync', () async {
      await alertService.syncDeliveries();

      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.deliveredAt, isNotNull,
            reason: 'deliveredAt ainda null após sync para assignment ${a.id}');
      }
    });

    test('deliveredAt não é sobrescrito pela segunda chamada', () async {
      await alertService.syncDeliveries();
      final before = await alertService.getMyAssignments();
      if (before.isEmpty) return;

      await alertService.syncDeliveries();
      final after = await alertService.getMyAssignments();

      for (final a in before) {
        if (a.deliveredAt == null) continue;
        final updated = after.firstWhere((b) => b.id == a.id);
        expect(updated.deliveredAt, equals(a.deliveredAt),
            reason: 'deliveredAt foi sobrescrito na segunda chamada para assignment ${a.id}');
      }
    });

    test('número de assignments não aumenta na segunda chamada', () async {
      await alertService.syncDeliveries();
      final before = await alertService.getMyAssignments();

      await alertService.syncDeliveries();
      final after = await alertService.getMyAssignments();

      expect(after.length, equals(before.length),
          reason: 'syncDeliveries duplicou assignments na segunda chamada');
    });
  });

  group('AlertService.getMyAssignments — isolamento por usuário', () {
    test('todos os assignments pertencem ao usuário autenticado', () async {
      final user = await authService.fetchProfile();
      final assignments = await alertService.getMyAssignments();

      for (final a in assignments) {
        expect(a.userId, equals(user.id),
            reason: 'assignment ${a.id} pertence a ${a.userId}, esperado ${user.id}');
      }
    });

    test('supervisor só vê seus próprios assignments em getMyAssignments', () async {
      await loginAsSupervisor(authService);
      await clearBlocking(alertService);
      final supervisor = await authService.fetchProfile();

      final assignments = await alertService.getMyAssignments();

      for (final a in assignments) {
        expect(a.userId, equals(supervisor.id),
            reason: 'assignment ${a.id} pertence a ${a.userId}, esperado ${supervisor.id}');
      }
    });
  });

  group('AlertService.getMyAssignments — filtro por status', () {
    setUp(() async {
      await loginAsEmployee(authService);
      await clearBlocking(alertService);
      await alertService.syncDeliveries();
    });

    test('filtro PENDING retorna somente assignments pendentes', () async {
      final pending =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.pending]);
      for (final a in pending) {
        expect(a.status, equals(AssignmentStatus.pending),
            reason: 'assignment ${a.id} tem status ${a.status}, esperado pending');
      }
    });

    test('filtro OVERDUE retorna somente assignments atrasados', () async {
      final overdue =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.overdue]);
      for (final a in overdue) {
        expect(a.status, equals(AssignmentStatus.overdue),
            reason: 'assignment ${a.id} tem status ${a.status}, esperado overdue');
      }
    });

    test('filtro ACKNOWLEDGED retorna somente assignments confirmados', () async {
      final acknowledged =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.acknowledged]);
      for (final a in acknowledged) {
        expect(a.status, equals(AssignmentStatus.acknowledged),
            reason: 'assignment ${a.id} tem status ${a.status}, esperado acknowledged');
      }
    });

    test('filtro multi-status PENDING+VIEWED exclui outros estados', () async {
      final results = await alertService.getMyAssignments(statuses: [
        AssignmentStatus.pending,
        AssignmentStatus.viewed,
      ]);
      for (final a in results) {
        expect(
          a.status == AssignmentStatus.pending || a.status == AssignmentStatus.viewed,
          isTrue,
          reason: 'assignment ${a.id} tem status ${a.status}, esperado pending ou viewed',
        );
      }
    });

    test('soma dos filtros por status é igual ao total sem filtro', () async {
      final all = await alertService.getMyAssignments();
      final pending =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.pending]);
      final viewed =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.viewed]);
      final acknowledged =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.acknowledged]);
      final overdue =
          await alertService.getMyAssignments(statuses: [AssignmentStatus.overdue]);

      final sumByStatus =
          pending.length + viewed.length + acknowledged.length + overdue.length;
      expect(sumByStatus, equals(all.length),
          reason: 'soma dos filtros ($sumByStatus) difere do total sem filtro (${all.length})');
    });
  });

  group('AlertService.getAllAssignments — campos enriquecidos (supervisor)', () {
    setUp(() async {
      await loginAsSupervisor(authService);
      await clearBlocking(alertService);
    });

    test('isBlocking e canAcknowledge estão presentes em todos os assignments', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.isBlocking, isNotNull,
            reason: 'isBlocking null em getAllAssignments para ${a.id}');
        expect(a.canAcknowledge, isNotNull,
            reason: 'canAcknowledge null em getAllAssignments para ${a.id}');
      }
    });
  });
}

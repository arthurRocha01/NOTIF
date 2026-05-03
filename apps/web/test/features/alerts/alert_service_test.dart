import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
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
    test('retorna lista de AssignmentModel', () async {
      final assignments = await alertService.getMyAssignments();
      expect(assignments, isA<List<AssignmentModel>>());
    });

    test('notificationTitle não é nulo nem vazio', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationTitle, isNotNull,
            reason: 'notificationTitle veio null para assignment ${a.id}');
        expect(a.notificationTitle, isNotEmpty,
            reason: 'notificationTitle veio vazio para assignment ${a.id}');
      }
    });

    test('notificationMessage não é nulo nem vazio', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationMessage, isNotNull,
            reason: 'notificationMessage veio null para assignment ${a.id}');
        expect(a.notificationMessage, isNotEmpty,
            reason: 'notificationMessage veio vazio para assignment ${a.id}');
      }
    });

    test('requiresAcknowledgment não é nulo', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.requiresAcknowledgment, isNotNull,
            reason:
                'requiresAcknowledgment veio null para assignment ${a.id}');
      }
    });

    test('notificationAuthorId é um UUID válido', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      final uuidPattern = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      );
      for (final a in assignments) {
        expect(a.notificationAuthorId, isNotNull,
            reason: 'notificationAuthorId veio null para assignment ${a.id}');
        expect(a.notificationAuthorId, matches(uuidPattern),
            reason:
                'notificationAuthorId não é UUID para assignment ${a.id}');
      }
    });

    test('notificationSlaMinutes é maior que zero', () async {
      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationSlaMinutes, isNotNull,
            reason: 'notificationSlaMinutes não deve ser nulo para assignment ${a.id}');
        expect(a.notificationSlaMinutes! > 0, isTrue,
            reason: 'notificationSlaMinutes deve ser maior que zero para assignment ${a.id}');
      }
    });
  });

  group('AlertService.syncDeliveries', () {
    test('completa sem erro para o employee logado', () async {
      await expectLater(
        alertService.syncDeliveries(),
        completes,
      );
    });

    test('assignments têm deliveredAt preenchido após sync', () async {
      await alertService.syncDeliveries();

      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.deliveredAt, isNotNull,
            reason:
                'deliveredAt ainda null após sync para assignment ${a.id}');
      }
    });

    test('segunda chamada a syncDeliveries completa sem erro', () async {
      await alertService.syncDeliveries();
      await expectLater(alertService.syncDeliveries(), completes);
    });

    test('deliveredAt não é alterado pela segunda chamada a syncDeliveries', () async {
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

    test('número de assignments não aumenta após segunda chamada a syncDeliveries',
        () async {
      await alertService.syncDeliveries();
      final before = await alertService.getMyAssignments();

      await alertService.syncDeliveries();
      final after = await alertService.getMyAssignments();

      expect(after.length, equals(before.length),
          reason: 'syncDeliveries duplicou assignments na segunda chamada');
    });
  });

  group('AlertService.markAsViewed', () {
    test('transiciona assignment PENDING para VIEWED', () async {
      await alertService.syncDeliveries();

      final assignments = await alertService.getMyAssignments();
      final pending = assignments
          .where((a) => a.status == AssignmentStatus.pending)
          .toList();
      if (pending.isEmpty) return;

      final target = pending.first;
      await alertService.markAsViewed(target.id);

      final updated = await alertService.getMyAssignments();
      final after = updated.firstWhere((a) => a.id == target.id);
      expect(after.status, equals(AssignmentStatus.viewed));
    });

    test('lança ApiException ao chamar markAsViewed em assignment já VIEWED',
        () async {
      final assignments = await alertService.getMyAssignments();
      final viewed = assignments
          .where((a) => a.status == AssignmentStatus.viewed)
          .toList();
      if (viewed.isEmpty) return;

      await expectLater(
        alertService.markAsViewed(viewed.first.id),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('visualizada'),
          ),
        ),
      );
    });
  });

  group('AlertService.acknowledge', () {
    test('transiciona assignment para ACKNOWLEDGED', () async {
      await alertService.syncDeliveries();

      final assignments = await alertService.getMyAssignments();
      final pending = assignments
          .where((a) =>
              a.status == AssignmentStatus.pending ||
              a.status == AssignmentStatus.viewed)
          .where((a) => a.canAcknowledge)
          .toList();
      if (pending.isEmpty) return;

      final target = pending.first;
      await alertService.acknowledge(target.id);

      final updated = await alertService.getMyAssignments();
      final after = updated.firstWhere((a) => a.id == target.id);
      expect(after.status, equals(AssignmentStatus.acknowledged));
    });
  });

  group('AlertService.createNotification — global (sectorId null)', () {
    late String supervisorId;

    setUp(() async {
      await loginAsSupervisor(authService);
      await clearBlocking(alertService);
      final supervisor = await authService.fetchUser(kSupervisorEmail);
      supervisorId = supervisor.id;
    });

    test('cria notificação global sem erro', () async {
      await expectLater(
        alertService.createNotification(
          title: 'Aviso Global Teste',
          message: 'Mensagem de aviso global para todos os setores.',
          level: AlertLevel.low,
          slaMinutes: 60,
          requiresAcknowledgment: false,
          sectorId: null,
        ),
        completes,
      );
    });

    test('notificação global tem sectorId nulo na resposta', () async {
      final notification = await alertService.createNotification(
        title: 'Aviso Global Verificação',
        message: 'Verificando que sectorId é null no retorno do backend.',
        level: AlertLevel.low,
        slaMinutes: 60,
        requiresAcknowledgment: false,
        sectorId: null,
      );
      expect(notification.targetSectorId, isNull);
      expect(notification.isGlobal, isTrue);
    });

    test('notificação setorial tem sectorId preenchido na resposta', () async {
      final notifications = await alertService.getNotifications();
      final setorial = notifications.where((n) => !n.isGlobal).toList();
      if (setorial.isEmpty) return;

      for (final n in setorial) {
        expect(n.targetSectorId, isNotNull);
        expect(n.targetSectorId, isNotEmpty);
      }
    });
  });

  group('AlertService.getMyAssignments — isolamento por usuário', () {
    test('todos os assignments pertencem ao usuário autenticado', () async {
      await clearBlocking(alertService);
      final user = await authService.fetchUser(kEmployeeEmail);
      final assignments = await alertService.getMyAssignments();

      for (final a in assignments) {
        expect(
          a.userId,
          equals(user.id),
          reason:
              'assignment ${a.id} pertence a ${a.userId}, esperado ${user.id}',
        );
      }
    });

    test('supervisor não recebe assignments de outros usuários em getMyAssignments',
        () async {
      await loginAsSupervisor(authService);
      await clearBlocking(alertService);
      final supervisor = await authService.fetchUser(kSupervisorEmail);

      final assignments = await alertService.getMyAssignments();

      for (final a in assignments) {
        expect(
          a.userId,
          equals(supervisor.id),
          reason:
              'assignment ${a.id} pertence a ${a.userId}, esperado ${supervisor.id}',
        );
      }
    });
  });

  group('AlertService.getAllAssignments — campos enriquecidos (supervisor)', () {
    setUp(() async {
      await loginAsSupervisor(authService);
      await clearBlocking(alertService);
    });

    test('retorna assignments com notificationTitle não nulo', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationTitle, isNotNull,
            reason:
                'notificationTitle null em getAllAssignments para ${a.id}');
      }
    });

    test('retorna assignments com notificationAuthorId não nulo', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.notificationAuthorId, isNotNull,
            reason:
                'notificationAuthorId null em getAllAssignments para ${a.id}');
      }
    });
  });
}

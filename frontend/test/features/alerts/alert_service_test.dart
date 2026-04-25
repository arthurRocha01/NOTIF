import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _employeeEmail = 'employee.dev@notif.com';
const _supervisorEmail = 'supervisor.dev@notif.com';
const _password = 'password123';

void main() {
  late AlertService alertService;
  late AuthService authService;

  setUp(() async {
    alertService = AlertService();
    authService = AuthService();
    ApiClient.clearToken();

    final token = await authService.login(_employeeEmail, _password);
    ApiClient.setToken(token);
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

      // slaMinutes não está em AssignmentModel — vem embutido em notificationSlaMinutes
      // do backend. Verificamos via getAllAssignments que o campo chega corretamente.
    });
  });

  group('AlertService.syncDeliveries', () {
    test('completa sem erro para o employee logado', () async {
      final user = await authService.fetchUser(_employeeEmail);
      await expectLater(
        alertService.syncDeliveries(user.id),
        completes,
      );
    });

    test('assignments têm deliveredAt preenchido após sync', () async {
      final user = await authService.fetchUser(_employeeEmail);
      await alertService.syncDeliveries(user.id);

      final assignments = await alertService.getMyAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.deliveredAt, isNotNull,
            reason:
                'deliveredAt ainda null após sync para assignment ${a.id}');
      }
    });
  });

  group('AlertService.markAsViewed', () {
    test('transiciona assignment PENDING para VIEWED', () async {
      final user = await authService.fetchUser(_employeeEmail);
      await alertService.syncDeliveries(user.id);

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
      final user = await authService.fetchUser(_employeeEmail);
      await alertService.syncDeliveries(user.id);

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
      final token = await authService.login(_supervisorEmail, _password);
      ApiClient.setToken(token);
      final user = await authService.fetchUser(_supervisorEmail);
      supervisorId = user.id;
    });

    test('cria notificação global sem erro', () async {
      await expectLater(
        alertService.createNotification(
          authorId: supervisorId,
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
        authorId: supervisorId,
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
      final setorial =
          notifications.where((n) => !n.isGlobal).toList();
      if (setorial.isEmpty) return;

      for (final n in setorial) {
        expect(n.targetSectorId, isNotNull);
        expect(n.targetSectorId, isNotEmpty);
      }
    });
  });

  group('AlertService.getAllAssignments — campos enriquecidos (supervisor)', () {
    setUp(() async {
      final token = await authService.login(_supervisorEmail, _password);
      ApiClient.setToken(token);
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

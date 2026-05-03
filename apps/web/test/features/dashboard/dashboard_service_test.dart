import 'package:flutter_test/flutter_test.dart';
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

    await loginAsSupervisor(authService);
    await clearBlocking(alertService);
  });

  group('AlertService.getAllAssignments', () {
    test('retorna lista de AssignmentModel', () async {
      final assignments = await alertService.getAllAssignments();
      expect(assignments, isA<List<AssignmentModel>>());
    });

    test('cada assignment tem id, userId e notificationId não vazios', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(a.id, isNotEmpty);
        expect(a.userId, isNotEmpty);
        expect(a.notificationId, isNotEmpty);
      }
    });

    test('status é um valor válido de AssignmentStatus', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(
          AssignmentStatus.values.contains(a.status),
          isTrue,
          reason: 'status inválido: ${a.status}',
        );
      }
    });

    test('notificationLevel é um valor válido de AlertLevel', () async {
      final assignments = await alertService.getAllAssignments();
      if (assignments.isEmpty) return;

      for (final a in assignments) {
        expect(
          AlertLevel.values.contains(a.notificationLevel),
          isTrue,
          reason: 'notificationLevel inválido: ${a.notificationLevel}',
        );
      }
    });
  });
}

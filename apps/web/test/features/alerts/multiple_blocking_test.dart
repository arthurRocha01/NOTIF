import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;

  late String firstAssignmentId;
  late String secondAssignmentId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();

    final supervisorToken = await loginAsSupervisor(authService);
    await clearBlocking(alertService);
    await loginAsEmployee(authService);
    await clearBlocking(alertService);

    ApiClient.setToken(supervisorToken);
    final employee = await authService.fetchUser(kEmployeeEmail);

    final notif1 = await alertService.createNotification(
      title: 'Bloqueio Crítico 1 TDD',
      message: 'Primeiro alerta crítico simultâneo.',
      level: AlertLevel.critical,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    final notif2 = await alertService.createNotification(
      title: 'Bloqueio Crítico 2 TDD',
      message: 'Segundo alerta crítico simultâneo.',
      level: AlertLevel.critical,
      slaMinutes: 60,
      requiresAcknowledgment: true,
      sectorId: employee.sectorId,
    );

    await loginAsEmployee(authService);
    await alertService.syncDeliveries();

    final blocking = await alertService.getBlockingAssignments();
    firstAssignmentId  = blocking.firstWhere((a) => a.notificationId == notif1.id).id;
    secondAssignmentId = blocking.firstWhere((a) => a.notificationId == notif2.id).id;
  });

  setUp(() async {
    await loginAsEmployee(authService);
  });

  group('Múltiplos bloqueios simultâneos — confirmação alerta por alerta', () {
    test('getBlockingAssignments retorna os dois assignments CRITICAL', () async {
      final blocking = await alertService.getBlockingAssignments();

      expect(blocking.any((a) => a.id == firstAssignmentId), isTrue);
      expect(blocking.any((a) => a.id == secondAssignmentId), isTrue);
    });

    test('GET /notifications retorna 403 com dois CRITICAL pendentes', () async {
      await expectLater(
        alertService.getNotifications(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('após confirmar o primeiro, o segundo ainda bloqueia', () async {
      await alertService.acknowledge(firstAssignmentId);

      final blocking = await alertService.getBlockingAssignments();
      expect(blocking.any((a) => a.id == secondAssignmentId), isTrue,
          reason: 'segundo CRITICAL ainda não confirmado deve continuar bloqueando');
    });

    test('GET /notifications ainda retorna 403 com um CRITICAL pendente', () async {
      await expectLater(
        alertService.getNotifications(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('após confirmar o segundo, getBlockingAssignments retorna vazio', () async {
      await alertService.acknowledge(secondAssignmentId);

      final blocking = await alertService.getBlockingAssignments();
      expect(blocking, isEmpty,
          reason: 'todos os CRITICAL confirmados — não deve haver mais bloqueios');
    });

    test('GET /notifications volta a funcionar após confirmar todos os CRITICAL', () async {
      final notifications = await alertService.getNotifications();
      expect(notifications, isA<List>());
    });
  });
}

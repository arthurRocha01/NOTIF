import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

const _kTokenA1 = '${kFakeToken}V1';
const _kTokenA2 = '${kFakeToken}V2';
const _kTokenB  = '${kFakeToken}B';

void main() {
  late AuthService service;
  late AlertService alertService;

  setUpAll(() async {
    service = AuthService();
    alertService = AlertService();

    await loginAsEmployee(service);
    await clearBlocking(alertService);

    await loginAs(service, kEmployeeOpsEmail);
    await clearBlocking(alertService);
  });

  setUp(() async {
    await loginAsEmployee(service);
  });

  group('updateFcmToken — comportamento básico', () {
    test('token novo sobrescreve o anterior', () async {
      await service.updateFcmToken(_kTokenA1);
      await service.updateFcmToken(_kTokenA2);
      final user = await service.fetchProfile();
      expect(user.fcmToken, equals(_kTokenA2));
    });

    test('PATCH com mesmo token é idempotente', () async {
      await service.updateFcmToken(_kTokenA1);
      await service.updateFcmToken(_kTokenA1);
      final user = await service.fetchProfile();
      expect(user.fcmToken, equals(_kTokenA1));
    });
  });

  group('updateFcmToken — employee bloqueado por CRITICAL', () {
    test('registra token FCM mesmo com CRITICAL não confirmado', () async {
      final employee = await service.fetchProfile();

      await loginAsSupervisor(service);
      await alertService.createNotification(
        title: 'CRITICAL para teste de FCM bloqueado',
        message: 'Valida que updateFcmToken funciona mesmo durante bloqueio.',
        level: AlertLevel.critical,
        slaMinutes: 60,
        requiresAcknowledgment: true,
        sectorId: employee.sectorId,
      );

      await loginAsEmployee(service);
      await alertService.syncDeliveries();

      final blocking = await alertService.getBlockingAssignments();
      expect(blocking, isNotEmpty, reason: 'employee deve estar bloqueado neste ponto');

      await service.updateFcmToken(_kTokenA1);

      final user = await service.fetchProfile();
      expect(user.fcmToken, equals(_kTokenA1));

      for (final a in blocking) {
        await alertService.acknowledge(a.id);
      }
    });
  });

  group('updateFcmToken — isolamento entre usuários', () {
    test('token de A não afeta token de B', () async {
      await loginAs(service, kEmployeeOpsEmail);
      await service.updateFcmToken(_kTokenB);

      await loginAsEmployee(service);
      await service.updateFcmToken(_kTokenA1);

      await loginAs(service, kEmployeeOpsEmail);
      final userB = await service.fetchProfile();
      expect(userB.fcmToken, equals(_kTokenB));
    });

    test('múltiplas atualizações de A não alteram token de B', () async {
      await loginAs(service, kEmployeeOpsEmail);
      await service.updateFcmToken(_kTokenB);

      await loginAsEmployee(service);
      await service.updateFcmToken(_kTokenA1);
      await service.updateFcmToken(_kTokenA2);

      await loginAs(service, kEmployeeOpsEmail);
      final userB = await service.fetchProfile();
      expect(userB.fcmToken, equals(_kTokenB));
    });
  });
}

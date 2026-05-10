import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AlertService alertService;
  late AuthService authService;
  late String supervisorSectorId;

  setUpAll(() async {
    alertService = AlertService();
    authService = AuthService();
    await loginAsSupervisor(authService);
    supervisorSectorId = (await authService.fetchProfile()).sectorId;
  });

  setUp(() async {
    await loginAsSupervisor(authService);
  });

  group('AlertService.getNotifications — filtro por level', () {
    test('filtro CRITICAL retorna somente notificações críticas', () async {
      final results = await alertService.getNotifications(level: AlertLevel.critical);
      for (final n in results) {
        expect(
          n.level,
          equals(AlertLevel.critical),
          reason: 'notificação ${n.id} tem level ${n.level}, esperado critical',
        );
      }
    });

    test('filtro LOW retorna somente notificações baixas', () async {
      final results = await alertService.getNotifications(level: AlertLevel.low);
      for (final n in results) {
        expect(
          n.level,
          equals(AlertLevel.low),
          reason: 'notificação ${n.id} tem level ${n.level}, esperado low',
        );
      }
    });

    test('filtro HIGH retorna somente notificações altas', () async {
      final results = await alertService.getNotifications(level: AlertLevel.high);
      for (final n in results) {
        expect(
          n.level,
          equals(AlertLevel.high),
          reason: 'notificação ${n.id} tem level ${n.level}, esperado high',
        );
      }
    });
  });

  group('AlertService.getNotifications — filtro por sectorId', () {
    test('filtro por sectorId retorna somente notificações do setor ou globais',
        () async {
      final results =
          await alertService.getNotifications(sectorId: supervisorSectorId);
      for (final n in results) {
        final matchesSector = n.isGlobal || n.targetSectorId == supervisorSectorId;
        expect(
          matchesSector,
          isTrue,
          reason:
              'notificação ${n.id} não pertence ao setor $supervisorSectorId nem é global',
        );
      }
    });

    test('sectorId inválido retorna apenas globais', () async {
      const fakeId = '00000000-0000-0000-0000-000000000000';
      final results = await alertService.getNotifications(sectorId: fakeId);
      for (final n in results) {
        expect(
          n.isGlobal,
          isTrue,
          reason:
              'notificação ${n.id} não é global mas foi retornada para sectorId inválido',
        );
      }
    });
  });

  group('AlertService.getNotifications — combinação de filtros', () {
    test('level + sectorId combinados filtram corretamente', () async {
      final results = await alertService.getNotifications(
        level: AlertLevel.critical,
        sectorId: supervisorSectorId,
      );
      for (final n in results) {
        expect(
          n.level,
          equals(AlertLevel.critical),
          reason: 'notificação ${n.id} tem level ${n.level}, esperado critical',
        );
        final matchesSector = n.isGlobal || n.targetSectorId == supervisorSectorId;
        expect(
          matchesSector,
          isTrue,
          reason: 'notificação ${n.id} não pertence ao setor filtrado',
        );
      }
    });

    test('resultado com filtro é subconjunto do resultado sem filtro', () async {
      final all = await alertService.getNotifications();
      final byCritical =
          await alertService.getNotifications(level: AlertLevel.critical);
      expect(
        all.length,
        greaterThanOrEqualTo(byCritical.length),
        reason: 'filtro por level retornou mais itens do que a lista completa',
      );
    });
  });
}

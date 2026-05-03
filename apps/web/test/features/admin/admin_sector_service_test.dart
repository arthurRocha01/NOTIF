import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AdminSectorService service;
  late AuthService authService;
  late AlertService alertService;

  setUp(() async {
    service = AdminSectorService();
    authService = AuthService();
    alertService = AlertService();

    await loginAs(authService, kAdminEmail);
    await clearBlocking(alertService);
  });

  group('AdminSectorService.getSectors', () {
    test('retorna lista de SectorModel', () async {
      final sectors = await service.getSectors();
      expect(sectors, isA<List<SectorModel>>());
    });

    test('cada setor tem id e name não vazios', () async {
      final sectors = await service.getSectors();
      expect(sectors, isNotEmpty);
      for (final s in sectors) {
        expect(s.id, isNotEmpty);
        expect(s.name, isNotEmpty);
      }
    });
  });

  group('AdminSectorService.createSector', () {
    test('cria setor e retorna com id preenchido', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final sector = await service.createSector('Setor Teste $ts');
      expect(sector.id, isNotEmpty);
      expect(sector.name, isNotEmpty);

      await service.deleteSector(sector.id);
    });

    test('rejeita nome duplicado com ApiException', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final name = 'Setor Duplicado $ts';
      final sector = await service.createSector(name);

      try {
        await expectLater(
          service.createSector(name),
          throwsA(isA<ApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            409,
          )),
        );
      } finally {
        await service.deleteSector(sector.id);
      }
    });
  });

  group('AdminSectorService.updateSector', () {
    test('atualiza nome e retorna setor atualizado', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final created = await service.createSector('Setor Original $ts');
      final updated = await service.updateSector(
        sectorId: created.id,
        name: 'Setor Renomeado $ts',
      );
      expect(updated.id, equals(created.id));
      expect(updated.name, equals('Setor Renomeado $ts'));

      await service.deleteSector(created.id);
    });
  });

  group('AdminSectorService.deleteSector', () {
    test('remove setor sem lançar exceção', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final created = await service.createSector('Setor Para Deletar $ts');
      await expectLater(service.deleteSector(created.id), completes);
    });

    test('setor removido não aparece mais na listagem', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final created = await service.createSector('Setor Efêmero $ts');
      await service.deleteSector(created.id);

      final sectors = await service.getSectors();
      expect(sectors.any((s) => s.id == created.id), isFalse);
    });

    test('apaga usuários vinculados ao setor', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final userService = AdminUserService();
      final sector = await service.createSector('Setor Com Users $ts');

      final user = await userService.createUser(
        name: 'User Do Setor TDD',
        email: 'tdd.sector.user.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: sector.id,
      );

      await service.deleteSector(sector.id);

      final users = await userService.getUsers();
      expect(users.any((u) => u.id == user.id), isFalse,
          reason: 'usuário do setor deletado deve ser removido junto');
    });

    test('apaga notificações setoriais vinculadas ao setor', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final sector = await service.createSector('Setor Com Notifs $ts');

      await loginAs(authService, kSupervisorEmail);
      await alertService.createNotification(
        title: 'Notif do Setor TDD',
        message: 'Deve ser removida ao deletar o setor.',
        level: AlertLevel.low,
        slaMinutes: 60,
        requiresAcknowledgment: false,
        sectorId: sector.id,
      );

      await loginAs(authService, kAdminEmail);
      await service.deleteSector(sector.id);

      final sectors = await service.getSectors();
      expect(sectors.any((s) => s.id == sector.id), isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  late AdminUserService service;
  late SectorService sectorService;
  late AuthService authService;
  late AlertService alertService;
  late String testSectorId;

  setUp(() async {
    service = AdminUserService();
    sectorService = SectorService();
    authService = AuthService();
    alertService = AlertService();

    await loginAs(authService, kAdminEmail);
    await clearBlocking(alertService);

    final sectors = await sectorService.getSectors();
    testSectorId = sectors.first.id;
  });

  group('AdminUserService.getUsers', () {
    test('retorna lista de UserModel', () async {
      final users = await service.getUsers();
      expect(users, isA<List<UserModel>>());
    });

    test('cada usuário tem id, name, email e sectorId não vazios', () async {
      final users = await service.getUsers();
      expect(users, isNotEmpty);
      for (final u in users) {
        expect(u.id, isNotEmpty);
        expect(u.name, isNotEmpty);
        expect(u.email, isNotEmpty);
        expect(u.sectorId, isNotEmpty);
      }
    });
  });

  group('AdminUserService.createUser', () {
    test('cria usuário EMPLOYEE e retorna com id preenchido', () async {
      final user = await service.createUser(
        name: 'Teste TDD',
        email: 'tdd.user.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );
      expect(user.id, isNotEmpty);
      expect(user.role, equals(UserRole.employee));

      await service.deleteUser(user.id);
    });

    test('cria usuário SUPERVISOR e retorna com role correto', () async {
      final user = await service.createUser(
        name: 'Supervisor TDD',
        email: 'tdd.sup.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: kPassword,
        role: 'SUPERVISOR',
        sectorId: testSectorId,
      );
      expect(user.role, equals(UserRole.supervisor));

      await service.deleteUser(user.id);
    });

    test('rejeita email duplicado com ApiException', () async {
      const duplicateEmail = 'tdd.dup@notif.com';
      final user = await service.createUser(
        name: 'Duplicado',
        email: duplicateEmail,
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );

      try {
        expect(
          () => service.createUser(
            name: 'Duplicado 2',
            email: duplicateEmail,
            password: kPassword,
            role: 'EMPLOYEE',
            sectorId: testSectorId,
          ),
          throwsA(isA<ApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            409,
          )),
        );
      } finally {
        await service.deleteUser(user.id);
      }
    });
  });

  group('AdminUserService.updateUser', () {
    late UserModel createdUser;

    setUp(() async {
      createdUser = await service.createUser(
        name: 'Usuario Para Editar',
        email: 'tdd.edit.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );
    });

    tearDown(() async {
      await service.deleteUser(createdUser.id);
    });

    test('atualiza name e retorna usuário com novo nome', () async {
      final updated = await service.updateUser(
        userId: createdUser.id,
        name: 'Nome Atualizado',
      );
      expect(updated.name, equals('Nome Atualizado'));
    });

    test('atualiza role de EMPLOYEE para SUPERVISOR', () async {
      final updated = await service.updateUser(
        userId: createdUser.id,
        role: 'SUPERVISOR',
      );
      expect(updated.role, equals(UserRole.supervisor));
    });

    test('rejeita email duplicado com 409', () async {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final other = await service.createUser(
        name: 'Outro Usuario TDD',
        email: 'tdd.other.$ts@notif.com',
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );

      try {
        await expectLater(
          service.updateUser(userId: createdUser.id, email: other.email),
          throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 409)),
        );
      } finally {
        await service.deleteUser(other.id);
      }
    });

    test('atualiza sectorId e retorna com novo setor', () async {
      final sectors = await sectorService.getSectors();
      if (sectors.length < 2) return;

      final newSectorId = sectors.firstWhere((s) => s.id != testSectorId).id;
      final updated = await service.updateUser(
        userId: createdUser.id,
        sectorId: newSectorId,
      );
      expect(updated.sectorId, equals(newSectorId));
    });
  });

  group('AdminUserService.deleteUser', () {
    test('remove usuário sem lançar exceção', () async {
      final user = await service.createUser(
        name: 'Para Deletar',
        email: 'tdd.del.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: kPassword,
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );
      await expectLater(service.deleteUser(user.id), completes);
    });
  });
}

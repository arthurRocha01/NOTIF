import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

const _adminEmail = 'admin.dev@notif.com';
const _password = 'password123';

void main() {
  late AdminUserService service;
  late AdminSectorService sectorService;
  late AuthService authService;
  late String testSectorId;

  setUp(() async {
    service = AdminUserService();
    sectorService = AdminSectorService();
    authService = AuthService();
    ApiClient.clearToken();

    final token = await authService.login(_adminEmail, _password);
    ApiClient.setToken(token);
    final alertService = AlertService();
    for (final a in await alertService.getBlockingAssignments()) {
      await alertService.acknowledge(a.id);
    }

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
        password: 'password123',
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
        password: 'password123',
        role: 'SUPERVISOR',
        sectorId: testSectorId,
      );
      expect(user.role, equals(UserRole.supervisor));

      await service.deleteUser(user.id);
    });
  });

  group('AdminUserService.updateUser', () {
    late UserModel createdUser;

    setUp(() async {
      createdUser = await service.createUser(
        name: 'Usuario Para Editar',
        email: 'tdd.edit.${DateTime.now().millisecondsSinceEpoch}@notif.com',
        password: 'password123',
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
        password: 'password123',
        role: 'EMPLOYEE',
        sectorId: testSectorId,
      );
      await expectLater(service.deleteUser(user.id), completes);
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';
class MockAdminUserService extends Mock implements AdminUserService {}

UserModel _makeUser({
  String id = 'user-1',
  String name = 'João',
  UserRole role = UserRole.employee,
}) =>
    UserModel(
      id: id,
      name: name,
      email: 'joao@test.com',
      sector: 'sector-1',
      role: role,
    );

ProviderContainer _makeContainer(MockAdminUserService mock) {
  return ProviderContainer(
    overrides: [
      adminUserServiceProvider.overrideWithValue(mock),
    ],
  );
}

void main() {
  late MockAdminUserService mockService;

  setUp(() {
    mockService = MockAdminUserService();
  });

  group('AdminUserNotifier.loadUsers', () {
    test('carrega usuários e atualiza estado', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeUser()]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();

      final state = container.read(adminUserProvider);
      expect(state.users, hasLength(1));
      expect(state.users.first.id, equals('user-1'));
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('isLoading fica false e errorMessage preenchido após erro', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenThrow(ApiException('Falha ao carregar'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();

      final state = container.read(adminUserProvider);
      expect(state.users, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });

  group('AdminUserNotifier.createUser', () {
    test('adiciona usuário à lista após criação', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => []);
      when(() => mockService.createUser(
            token: any(named: 'token'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            sectorId: any(named: 'sectorId'),
          )).thenAnswer((_) async => _makeUser());

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();
      await container.read(adminUserProvider.notifier).createUser(
            name: 'João',
            email: 'joao@test.com',
            password: 'senha123',
            role: 'EMPLOYEE',
            sectorId: 'sector-1',
          );

      final state = container.read(adminUserProvider);
      expect(state.users, hasLength(1));
      expect(state.users.first.id, equals('user-1'));
    });

    test('errorMessage preenchido quando criação falha', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => []);
      when(() => mockService.createUser(
            token: any(named: 'token'),
            name: any(named: 'name'),
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            sectorId: any(named: 'sectorId'),
          )).thenThrow(ApiException('Email já em uso'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();
      await container.read(adminUserProvider.notifier).createUser(
            name: 'X',
            email: 'x@x.com',
            password: '123',
            role: 'EMPLOYEE',
            sectorId: 'sector-1',
          );

      expect(container.read(adminUserProvider).errorMessage, isNotNull);
    });
  });

  group('AdminUserNotifier.updateUser', () {
    test('substitui usuário atualizado na lista', () async {
      final original = _makeUser(name: 'Nome Antigo');
      final updated = _makeUser(name: 'Nome Novo');

      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => [original]);
      when(() => mockService.updateUser(
            token: any(named: 'token'),
            userId: any(named: 'userId'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => updated);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();
      await container.read(adminUserProvider.notifier).updateUser(
            userId: 'user-1',
            name: 'Nome Novo',
          );

      expect(
          container.read(adminUserProvider).users.first.name, equals('Nome Novo'));
    });
  });

  group('AdminUserNotifier.deleteUser', () {
    test('remove usuário da lista após deleção', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeUser()]);
      when(() => mockService.deleteUser(
            token: any(named: 'token'),
            userId: any(named: 'userId'),
          )).thenAnswer((_) async {});

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();
      await container.read(adminUserProvider.notifier).deleteUser('user-1');

      expect(container.read(adminUserProvider).users, isEmpty);
    });

    test('errorMessage preenchido quando deleção falha', () async {
      when(() => mockService.getUsers(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeUser()]);
      when(() => mockService.deleteUser(
            token: any(named: 'token'),
            userId: any(named: 'userId'),
          )).thenThrow(ApiException('Usuário não encontrado'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container.read(adminUserProvider.notifier).loadUsers();
      await container.read(adminUserProvider.notifier).deleteUser('user-1');

      expect(container.read(adminUserProvider).errorMessage, isNotNull);
      expect(container.read(adminUserProvider).users, hasLength(1));
    });
  });
}

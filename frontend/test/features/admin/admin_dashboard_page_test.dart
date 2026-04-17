import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/admin/screens/admin_dashboard_page.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/login/services/fcm_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAuthService extends Mock implements AuthService {}

class MockAdminUserService extends Mock implements AdminUserService {}

class MockAdminSectorService extends Mock implements AdminSectorService {}

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeTokenStorage extends Fake implements TokenStorage {
  @override Future<void> saveToken(String t) async {}
  @override Future<void> saveEmail(String e) async {}
  @override Future<String?> getToken() async => null;
  @override Future<String?> getEmail() async => null;
  @override Future<void> clearAll() async {}
}

class _FakeFcmService extends Fake implements FcmService {
  @override Future<String?> getToken() async => null;
  @override Future<void> requestPermission() async {}
}

class _FakeSectorService extends Fake implements SectorService {
  @override
  Future<List<SectorModel>> getSectors({required String token}) async => [];
}

class _FakeAlertService extends Fake implements AlertService {
  @override
  Future<void> syncDeliveries(
      {required String userId, required String token}) async {}
}

// ── Stub notifiers ─────────────────────────────────────────────────────────────

class _StubAdminUserNotifier extends AdminUserNotifier {
  _StubAdminUserNotifier(List<UserModel> users)
      : super(MockAdminUserService()) {
    state = AdminUserState(users: users);
  }

  @override
  Future<void> loadUsers() async {}
}

class _StubAdminSectorNotifier extends AdminSectorNotifier {
  _StubAdminSectorNotifier(List<SectorModel> sectors)
      : super(MockAdminSectorService(), _FakeSectorService()) {
    state = AdminSectorState(sectors: sectors);
  }

  @override
  Future<void> loadSectors() async {}
}

// ── Helpers ───────────────────────────────────────────────────────────────────

final _adminUser = UserModel(
  id: 'admin-1',
  name: 'Carlos Admin',
  email: 'admin@test.com',
  sector: '',
  role: UserRole.admin,
);

UserModel _user(String id, UserRole role) => UserModel(
      id: id,
      name: 'User $id',
      email: '$id@test.com',
      sector: 'sector-1',
      role: role,
    );

// 5 usuários: 2 supervisores + 3 funcionários | 4 setores
final _defaultUsers = [
  _user('1', UserRole.supervisor),
  _user('2', UserRole.supervisor),
  _user('3', UserRole.employee),
  _user('4', UserRole.employee),
  _user('5', UserRole.employee),
];

final _defaultSectors = [
  SectorModel(id: 's1', name: 'TI'),
  SectorModel(id: 's2', name: 'RH'),
  SectorModel(id: 's3', name: 'Financeiro'),
  SectorModel(id: 's4', name: 'Operações'),
];

Widget _buildSubject({
  List<UserModel>? users,
  List<SectorModel>? sectors,
}) {
  final mockAuth = MockAuthService();

  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) {
        final notifier = AuthNotifier(
          mockAuth,
          _FakeTokenStorage(),
          _FakeSectorService(),
          _FakeAlertService(),
          _FakeFcmService(),
        );
        // ignore: invalid_use_of_protected_member
        notifier.state = _adminUser;
        return notifier;
      }),
      adminUserProvider.overrideWith(
        (_) => _StubAdminUserNotifier(users ?? _defaultUsers),
      ),
      adminSectorProvider.overrideWith(
        (_) => _StubAdminSectorNotifier(sectors ?? _defaultSectors),
      ),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: AdminDashboardPage(
          onNavigateToUsers: () {},
          onNavigateToSectors: () {},
        ),
      ),
    ),
  );
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  group('AdminDashboardPage — stats', () {
    testWidgets('exibe total de usuários correto', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('stat-total')),
          matching: find.text('5'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe contagem de supervisores', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('stat-supervisors')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe contagem de funcionários', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('stat-employees')),
          matching: find.text('3'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe contagem de setores', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('stat-sectors')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('exibe nome do admin no cabeçalho', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pump();

      expect(find.textContaining('Carlos'), findsOneWidget);
    });
  });

  group('AdminDashboardPage — quick access', () {
    testWidgets('botão Usuários dispara onNavigateToUsers', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) {
              final notifier = AuthNotifier(
                MockAuthService(),
                _FakeTokenStorage(),
                _FakeSectorService(),
                _FakeAlertService(),
                _FakeFcmService(),
              );
              // ignore: invalid_use_of_protected_member
              notifier.state = _adminUser;
              return notifier;
            }),
            adminUserProvider
                .overrideWith((_) => _StubAdminUserNotifier(_defaultUsers)),
            adminSectorProvider.overrideWith(
                (_) => _StubAdminSectorNotifier(_defaultSectors)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdminDashboardPage(
                onNavigateToUsers: () => called = true,
                onNavigateToSectors: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('quick-users')));
      await tester.tap(find.byKey(const Key('quick-users')));
      expect(called, isTrue);
    });

    testWidgets('botão Setores dispara onNavigateToSectors', (tester) async {
      bool called = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) {
              final notifier = AuthNotifier(
                MockAuthService(),
                _FakeTokenStorage(),
                _FakeSectorService(),
                _FakeAlertService(),
                _FakeFcmService(),
              );
              // ignore: invalid_use_of_protected_member
              notifier.state = _adminUser;
              return notifier;
            }),
            adminUserProvider
                .overrideWith((_) => _StubAdminUserNotifier(_defaultUsers)),
            adminSectorProvider.overrideWith(
                (_) => _StubAdminSectorNotifier(_defaultSectors)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AdminDashboardPage(
                onNavigateToUsers: () {},
                onNavigateToSectors: () => called = true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('quick-sectors')));
      await tester.tap(find.byKey(const Key('quick-sectors')));
      expect(called, isTrue);
    });
  });
}

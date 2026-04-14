import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/profile/screen/account_screen.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAuthService extends Mock implements AuthService {}

class _FakeTokenStorage extends Fake implements TokenStorage {
  @override Future<void> saveToken(String token) async {}
  @override Future<void> saveEmail(String email) async {}
  @override Future<String?> getToken() async => null;
  @override Future<String?> getEmail() async => null;
  @override Future<void> clearAll() async {}
}

class _FakeSectorService extends Fake implements SectorService {
  @override
  Future<List<SectorModel>> getSectors({required String token}) async => [];
}

class _FakeAlertService extends Fake implements AlertService {
  @override
  Future<void> syncDeliveries({required String userId, required String token}) async {}
}

Widget _makeTestable({UserModel? user}) {
  final mockService = MockAuthService();
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(mockService),
      authProvider.overrideWith((ref) {
        final n = AuthNotifier(mockService, _FakeTokenStorage(), _FakeSectorService(), _FakeAlertService());
        // ignore: invalid_use_of_protected_member
        if (user != null) n.state = user;
        return n;
      }),
    ],
    child: const MaterialApp(home: AccountScreen()),
  );
}

void main() {
  final user = UserModel(
    id: 'u1',
    name: 'João Silva',
    email: 'joao@test.com',
    sector: 'Logística',
    role: UserRole.employee,
  );

  group('AccountScreen — estrutura (H1: visibilidade)', () {
    testWidgets('exibe título "Dados da conta"', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.text('Dados da conta'), findsOneWidget);
    });

    testWidgets('exibe email do usuário logado', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.textContaining('joao@test.com'), findsOneWidget);
    });

    testWidgets('exibe setor do usuário', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.textContaining('Logística'), findsOneWidget);
    });

    testWidgets('exibe cargo do usuário', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.textContaining('Funcionário'), findsOneWidget);
    });

    testWidgets('exibe botão de trocar senha', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.text('Trocar senha'), findsOneWidget);
    });

    testWidgets('exibe botão de recuperar senha', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      expect(find.text('Recuperar senha'), findsOneWidget);
    });
  });

  group('AccountScreen — trocar senha (H5: prevenção de erros)', () {
    testWidgets('tocar em Trocar senha abre modal', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      await tester.tap(find.text('Trocar senha'));
      await tester.pumpAndSettle();

      expect(find.text('Trocar senha'), findsWidgets);
      expect(find.text('Senha atual'), findsOneWidget);
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.text('Confirmar nova senha'), findsOneWidget);
    });

    testWidgets('modal exibe erro se nova senha diferente da confirmação', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      await tester.tap(find.text('Trocar senha'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('currentPassword')), 'senha123');
      await tester.enterText(find.byKey(const Key('newPassword')), 'nova123');
      await tester.enterText(find.byKey(const Key('confirmPassword')), 'diferente');

      await tester.tap(find.text('Confirmar'));
      await tester.pump();

      expect(find.textContaining('não coincidem'), findsOneWidget);
    });

    testWidgets('modal exibe erro se nova senha tiver menos de 6 caracteres', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      await tester.tap(find.text('Trocar senha'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('currentPassword')), 'senha123');
      await tester.enterText(find.byKey(const Key('newPassword')), '123');
      await tester.enterText(find.byKey(const Key('confirmPassword')), '123');

      await tester.tap(find.text('Confirmar'));
      await tester.pump();

      expect(find.textContaining('mínimo 6'), findsOneWidget);
    });

    testWidgets('campos de senha são obscuros por padrão', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      await tester.tap(find.text('Trocar senha'));
      await tester.pumpAndSettle();

      final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(fields.every((f) => f.obscureText), isTrue);
    });
  });

  group('AccountScreen — recuperar senha (H4: consistência)', () {
    testWidgets('tocar em Recuperar senha abre confirmação com email', (tester) async {
      await tester.pumpWidget(_makeTestable(user: user));
      await tester.tap(find.text('Recuperar senha'));
      await tester.pumpAndSettle();

      expect(find.textContaining('joao@test.com'), findsWidgets);
      expect(find.text('Enviar'), findsOneWidget);
    });
  });
}

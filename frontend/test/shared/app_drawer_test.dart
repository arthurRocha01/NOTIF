import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/login/services/fcm_service.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';

class MockAuthService extends Mock implements AuthService {}
class MockTokenStorage extends Mock implements TokenStorage {}

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

class _FakeFcmService extends Fake implements FcmService {
  @override
  Future<String?> getToken() async => null;
}

// Widget de suporte que abre o drawer automaticamente
Widget _makeTestable({UserModel? user}) {
  final mockService = MockAuthService();

  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(mockService),
      authProvider.overrideWith((ref) {
        final notifier = AuthNotifier(mockService, _FakeTokenStorage(), _FakeSectorService(), _FakeAlertService(), _FakeFcmService());
        if (user != null) {
          // ignore: invalid_use_of_protected_member
          notifier.state = user;
        }
        return notifier;
      }),
    ],
    child: const MaterialApp(
      home: Scaffold(
        drawer: AppDrawer(),
        body: SizedBox.shrink(),
      ),
    ),
  );
}

Future<void> _openDrawer(WidgetTester tester) async {
  final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffoldState.openDrawer();
  await tester.pumpAndSettle();
}

void main() {
  final supervisor = UserModel(
    id: 'sup-01',
    name: 'Roberta Lima',
    email: 'roberta@test.com',
    sector: 'Operações',
    role: UserRole.supervisor,
  );

  final employee = UserModel(
    id: 'emp-01',
    name: 'João Silva',
    email: 'joao@test.com',
    sector: 'Logística',
    role: UserRole.employee,
  );

  group('AppDrawer — dados do usuário (H2: linguagem do usuário)', () {
    testWidgets('exibe nome completo do usuário logado', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      expect(find.text('Roberta Lima'), findsOneWidget);
    });

    testWidgets('exibe roleLabel legível, não enum bruto', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      // roleLabel é exibido concatenado com setor: "Supervisor · Operações"
      expect(find.textContaining(supervisor.roleLabel), findsOneWidget);
      expect(find.textContaining('UserRole'), findsNothing);
      expect(find.textContaining('SUPERVISOR'), findsNothing);
    });

    testWidgets('exibe setor humanizado, não UUID', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      expect(find.textContaining('Operações'), findsOneWidget);
    });

    testWidgets('employee exibe roleLabel correto', (tester) async {
      await tester.pumpWidget(_makeTestable(user: employee));
      await _openDrawer(tester);

      // roleLabel concatenado com setor: "Funcionário · Logística"
      expect(find.textContaining(employee.roleLabel), findsOneWidget);
      expect(find.textContaining('EMPLOYEE'), findsNothing);
    });
  });

  group('AppDrawer — item Encerrar (H4: consistência visual)', () {
    testWidgets('item Encerrar está visível', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      expect(find.text('Encerrar sessão'), findsOneWidget);
    });

    testWidgets('texto do item Encerrar é vermelho', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      final text = tester.widget<Text>(find.text('Encerrar sessão'));
      expect(text.style?.color, equals(Colors.red));
    });
  });

  group('AppDrawer — logout (H5: prevenção de erros)', () {
    testWidgets('tocar em Encerrar abre diálogo de confirmação', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      await tester.tap(find.text('Encerrar sessão'));
      await tester.pumpAndSettle();

      expect(find.text('Encerrar sessão?'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('confirmar logout chama authProvider.logout sem crash',
        (tester) async {
      late ProviderContainer container;

      await tester.pumpWidget(
        ProviderScope(
          child: Builder(builder: (context) {
            container = ProviderScope.containerOf(context);
            return const MaterialApp(
              home: Scaffold(drawer: AppDrawer(), body: SizedBox.shrink()),
            );
          }),
          overrides: [
            authServiceProvider.overrideWithValue(MockAuthService()),
            authProvider.overrideWith((ref) {
              final n = AuthNotifier(MockAuthService(), _FakeTokenStorage(), _FakeSectorService(), _FakeAlertService(), _FakeFcmService());
              // ignore: invalid_use_of_protected_member
              n.state = supervisor;
              return n;
            }),
          ],
        ),
      );

      final scaffoldState = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffoldState.openDrawer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Encerrar sessão'));
      await tester.pumpAndSettle();

      // Toca em Sair — não usa pumpAndSettle pois CircularProgressIndicator
      // exibido quando user==null tem animação infinita
      await tester.tap(find.text('Sair'));
      await tester.pump();

      // Provider deve ter estado null após logout
      expect(container.read(authProvider), isNull);
    });

    testWidgets('cancelar logout fecha o diálogo', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      await tester.tap(find.text('Encerrar sessão'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Diálogo fechou, mas drawer pode ainda estar aberto
      expect(find.text('Encerrar sessão?'), findsNothing);
    });
  });

  group('AppDrawer — itens de navegação (H1: visibilidade do status)', () {
    testWidgets('exibe seções Biblioteca e Sistema', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      expect(find.textContaining('BIBLIOTECA'), findsOneWidget);
      expect(find.textContaining('SISTEMA'), findsOneWidget);
    });

    testWidgets('exibe itens de menu esperados', (tester) async {
      await tester.pumpWidget(_makeTestable(user: supervisor));
      await _openDrawer(tester);

      expect(find.text('Manuais & Políticas'), findsOneWidget);
      expect(find.text('Políticas de Segurança'), findsOneWidget);
      expect(find.text('Dados da conta'), findsOneWidget);
      expect(find.text('Suporte'), findsOneWidget);
    });
  });
}

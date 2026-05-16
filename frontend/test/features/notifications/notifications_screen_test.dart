import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/login/services/fcm_service.dart';
import 'package:notif_app/features/notifications/screens/notifications_screen.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

// ── Mocks / Fakes ─────────────────────────────────────────────────────────────

class MockAlertService extends Mock implements AlertService {}

class _FakeAuthService extends Fake implements AuthService {}

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

class _FakeFcmService extends Fake implements FcmService {
  @override Future<String?> getToken() async => null;
}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service, AlertState initialState) {
    state = initialState;
  }

  @override Future<void> loadAssignments({String? token}) async {}
  @override Future<void> loadNotifications({String? token}) async {}
}

// ── Modelos de teste ──────────────────────────────────────────────────────────

const _employee = UserModel(
  id: 'emp-01',
  name: 'João Silva',
  email: 'joao@test.com',
  sector: 'Logística',
  role: UserRole.employee,
);

AssignmentModel _makeAssignment({
  String id = 'a1',
  String title = 'Alerta Teste',
  String message = 'Mensagem do alerta de teste aqui',
  AlertLevel level = AlertLevel.low,
  AssignmentStatus status = AssignmentStatus.pending,
  bool requiresAcknowledgment = false,
}) =>
    AssignmentModel(
      id: id,
      userId: 'u1',
      notificationId: 'n1',
      notificationTitle: title,
      notificationMessage: message,
      notificationLevel: level,
      status: status,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      requiresAcknowledgment: requiresAcknowledgment,
    );

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _build({
  AlertState alertState = const AlertState(),
  UserModel? user,
}) {
  final service = MockAlertService();
  final stub = _StubAlertNotifier(service, alertState);

  return ProviderScope(
    overrides: [
      alertProvider.overrideWith((_) => stub),
      authProvider.overrideWith((ref) {
        final n = AuthNotifier(
          _FakeAuthService(),
          _FakeTokenStorage(),
          _FakeSectorService(),
          service,
          _FakeFcmService(),
        );
        if (user != null) {
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          n.state = user;
        }
        return n;
      }),
    ],
    child: const MaterialApp(home: NotificationsScreen()),
  );
}

// ── Testes ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  group('NotificationsScreen — header', () {
    testWidgets('exibe nome do usuário no cabeçalho', (tester) async {
      await tester.pumpWidget(_build(user: _employee));
      await tester.pump();

      expect(find.text('João Silva'), findsOneWidget);
    });

    testWidgets('renderiza sem crash com estado vazio', (tester) async {
      await tester.pumpWidget(_build(user: _employee));
      await tester.pump();

      expect(find.byType(NotificationsScreen), findsOneWidget);
    });
  });

  group('NotificationsScreen — filtros', () {
    testWidgets('exibe chips de filtro', (tester) async {
      await tester.pumpWidget(_build(user: _employee));
      await tester.pump();

      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Pendente'), findsOneWidget);
      expect(find.text('Atrasado'), findsOneWidget);
      expect(find.text('Confirmado'), findsOneWidget);
    });
  });

  group('NotificationsScreen — lista', () {
    testWidgets('exibe assignment na caixa de entrada', (tester) async {
      final state = AlertState(
        assignments: [_makeAssignment(title: 'Alerta de Incêndio')],
      );

      await tester.pumpWidget(_build(alertState: state, user: _employee));
      await tester.pump();

      expect(find.text('Alerta de Incêndio'), findsOneWidget);
    });

    testWidgets('exibe "Caixa de entrada" com contagem', (tester) async {
      final state = AlertState(
        assignments: [_makeAssignment(), _makeAssignment(id: 'a2')],
      );

      await tester.pumpWidget(_build(alertState: state, user: _employee));
      await tester.pump();

      expect(find.text('CAIXA DE ENTRADA'), findsOneWidget);
    });
  });

  group('NotificationsScreen — loading', () {
    testWidgets('exibe CircularProgressIndicator quando isLoadingAssignments',
        (tester) async {
      await tester.pumpWidget(_build(
        alertState: const AlertState(isLoadingAssignments: true),
        user: _employee,
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('NotificationsScreen — card crítico', () {
    testWidgets('exibe card URGENTE quando há assignment crítico bloqueante',
        (tester) async {
      final state = AlertState(
        assignments: [
          _makeAssignment(
            level: AlertLevel.critical,
            status: AssignmentStatus.pending,
          ),
        ],
      );

      await tester.pumpWidget(_build(alertState: state, user: _employee));
      await tester.pump();

      expect(find.text('URGENTE'), findsOneWidget);
      expect(find.text('Estou ciente'), findsOneWidget);
    });

    testWidgets('não exibe card URGENTE quando não há crítico bloqueante',
        (tester) async {
      final state = AlertState(
        assignments: [
          _makeAssignment(
            level: AlertLevel.low,
            status: AssignmentStatus.pending,
          ),
        ],
      );

      await tester.pumpWidget(_build(alertState: state, user: _employee));
      await tester.pump();

      expect(find.text('URGENTE'), findsNothing);
    });
  });

  group('NotificationsScreen — erro', () {
    testWidgets('exibe SnackBar quando errorMessage é setado', (tester) async {
      final service = MockAlertService();
      final notifier = _StubAlertNotifier(service, const AlertState());

      await tester.pumpWidget(ProviderScope(
        overrides: [
          alertProvider.overrideWith((_) => notifier),
          authProvider.overrideWith((ref) {
            final n = AuthNotifier(
              _FakeAuthService(),
              _FakeTokenStorage(),
              _FakeSectorService(),
              service,
              _FakeFcmService(),
            );
            // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
            n.state = _employee;
            return n;
          }),
        ],
        child: const MaterialApp(home: NotificationsScreen()),
      ));
      await tester.pump();

      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      notifier.state = const AlertState(errorMessage: 'Erro de conexão');
      await tester.pump();

      expect(find.text('Erro de conexão'), findsOneWidget);
    });
  });
}

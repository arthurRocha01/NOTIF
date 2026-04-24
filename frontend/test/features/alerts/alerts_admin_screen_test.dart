import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockSectorService extends Mock implements SectorService {}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service, AlertState initialState) {
    state = initialState;
  }

  @override
  Future<void> loadNotifications({String? token}) async {}

  @override
  Future<void> loadAssignments({String? token}) async {}
}

class _TrackingAlertNotifier extends AlertNotifier {
  final List<String> calls = [];

  _TrackingAlertNotifier(super.service) {
    state = const AlertState();
  }

  @override
  Future<void> loadNotifications({String? token}) async {
    calls.add('loadNotifications');
  }

  @override
  Future<void> loadAssignments({String? token}) async {
    calls.add('loadAssignments');
  }
}

class _StubSectorNotifier extends SectorNotifier {
  _StubSectorNotifier(super.service) {
    state = const SectorState();
  }

  @override
  Future<void> loadSectors({String? token}) async {}
}

Widget buildSubject({
  AlertState alertState = const AlertState(),
  SectorState sectorState = const SectorState(),
}) {
  final alertService = MockAlertService();
  final sectorService = MockSectorService();

  return ProviderScope(
    overrides: [
      alertProvider.overrideWith(
          (_) => _StubAlertNotifier(alertService, alertState)),
      sectorProvider.overrideWith((_) => _StubSectorNotifier(sectorService)),
    ],
    child: const MaterialApp(home: AlertAdminScreen()),
  );
}

AlertModel _makeAlert({
  required String id,
  required String title,
  required AlertLevel level,
}) =>
    AlertModel(
      id: id,
      title: title,
      message: 'Mensagem de teste com pelo menos dez caracteres',
      level: level,
      slaMinutes: 30,
      requiresAcknowledgment: false,
      createdAt: DateTime(2026, 4, 18),
    );

void main() {
  group('AlertAdminScreen tabs', () {
    testWidgets('exibe a aba Painel', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Painel'), findsOneWidget);
    });

    testWidgets('não exibe a aba Histórico', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Histórico'), findsNothing);
    });

    testWidgets('exibe a aba Minhas notificações', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Minhas notificações'), findsOneWidget);
    });
  });

  group('AlertAdminScreen init', () {
    testWidgets('não chama loads ao inicializar (delegado ao HomeScreen)',
        (tester) async {
      final notifier = _TrackingAlertNotifier(MockAlertService());
      final sectorService = MockSectorService();

      await tester.pumpWidget(ProviderScope(
        overrides: [
          alertProvider.overrideWith((_) => notifier),
          sectorProvider.overrideWith(
              (_) => _StubSectorNotifier(sectorService)),
        ],
        child: const MaterialApp(home: AlertAdminScreen()),
      ));
      await tester.pump();

      expect(notifier.calls, isEmpty);
    });
  });

  group('AlertAdminScreen filtro por nível', () {
    testWidgets('exibe chips de nível na aba Notificações', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Crítico'), findsOneWidget);
      expect(find.text('Médio'), findsOneWidget);
      expect(find.text('Baixo'), findsOneWidget);
    });

    testWidgets('filtra e exibe apenas alertas críticos ao selecionar "Crítico"',
        (tester) async {
      final state = AlertState(
        notifications: [
          _makeAlert(id: '1', title: 'Alerta Crítico', level: AlertLevel.critical),
          _makeAlert(id: '2', title: 'Alerta Baixo', level: AlertLevel.low),
        ],
      );

      await tester.pumpWidget(buildSubject(alertState: state));
      await tester.pump();

      // .first: chip de nível é renderizado antes dos badges dos cards
      await tester.tap(find.text('Crítico').first);
      await tester.pump();

      expect(find.text('Alerta Crítico'), findsOneWidget);
      expect(find.text('Alerta Baixo'), findsNothing);
    });

    testWidgets('exibe todos os alertas ao selecionar "Todos" após filtrar',
        (tester) async {
      final state = AlertState(
        notifications: [
          _makeAlert(id: '1', title: 'Alerta Crítico', level: AlertLevel.critical),
          _makeAlert(id: '2', title: 'Alerta Baixo', level: AlertLevel.low),
        ],
      );

      await tester.pumpWidget(buildSubject(alertState: state));
      await tester.pump();

      await tester.tap(find.text('Crítico').first);
      await tester.pump();
      // .first: chip "Todos" de nível (antes do chip "Todos" de setor)
      await tester.tap(find.text('Todos').first);
      await tester.pump();

      expect(find.text('Alerta Crítico'), findsOneWidget);
      expect(find.text('Alerta Baixo'), findsOneWidget);
    });
  });
}

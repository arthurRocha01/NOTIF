import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_user_screen.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

class _TrackingAlertNotifier extends AlertNotifier {
  final List<String> calls = [];

  _TrackingAlertNotifier(super.service) {
    state = const AlertState();
  }

  @override
  Future<void> loadAssignments({String? token}) async {
    calls.add('loadAssignments');
  }

  @override
  Future<void> markAllPendingAsViewed({String? token}) async {
    calls.add('markAllPendingAsViewed');
  }
}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service) {
    state = const AlertState();
  }

  @override
  Future<void> loadAssignments({String? token}) async {}

  @override
  Future<void> markAllPendingAsViewed({String? token}) async {}
}

Widget buildSubject({AlertNotifier? notifier}) {
  final service = MockAlertService();
  return ProviderScope(
    overrides: [
      alertProvider.overrideWith(
          (_) => notifier ?? _StubAlertNotifier(service)),
    ],
    child: const MaterialApp(home: AlertUserScreen()),
  );
}

void main() {
  group('AlertUserScreen init', () {
    testWidgets('não chama loadAssignments ao inicializar (delegado ao HomeScreen)',
        (tester) async {
      final notifier = _TrackingAlertNotifier(MockAlertService());

      await tester.pumpWidget(buildSubject(notifier: notifier));
      await tester.pump();

      expect(notifier.calls, isNot(contains('loadAssignments')));
    });

    testWidgets('não chama markAllPendingAsViewed ao inicializar',
        (tester) async {
      final notifier = _TrackingAlertNotifier(MockAlertService());

      await tester.pumpWidget(buildSubject(notifier: notifier));
      await tester.pump();

      expect(notifier.calls, isNot(contains('markAllPendingAsViewed')));
    });

    testWidgets('não dispara nenhuma chamada no initState', (tester) async {
      final notifier = _TrackingAlertNotifier(MockAlertService());

      await tester.pumpWidget(buildSubject(notifier: notifier));
      await tester.pump();

      expect(notifier.calls, isEmpty);
    });
  });

  group('AlertUserScreen layout', () {
    testWidgets('exibe lista de assignments via AssignmentsBody', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Minhas Notificações'), findsOneWidget);
    });
  });
}

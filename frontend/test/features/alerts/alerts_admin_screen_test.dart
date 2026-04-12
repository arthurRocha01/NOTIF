import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockSectorService extends Mock implements SectorService {}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service) {
    state = const AlertState();
  }

  @override
  Future<void> loadNotifications({String? token}) async {}

  @override
  Future<void> loadAssignments({String? token}) async {}
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
      alertProvider.overrideWith((_) => _StubAlertNotifier(alertService)),
      sectorProvider.overrideWith((_) => _StubSectorNotifier(sectorService)),
    ],
    child: const MaterialApp(home: AlertAdminScreen()),
  );
}

void main() {
  group('AlertAdminScreen tabs', () {
    testWidgets('exibe a aba Notificações', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('não exibe a aba Histórico', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.text('Histórico'), findsNothing);
    });
  });
}

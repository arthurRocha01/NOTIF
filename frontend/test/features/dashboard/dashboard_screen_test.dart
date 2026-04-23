import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

class MockAlertService extends Mock implements AlertService {}

class MockSectorService extends Mock implements SectorService {}

class _TrackingAlertNotifier extends AlertNotifier {
  final List<String> calls = [];

  _TrackingAlertNotifier(super.service) : super();

  @override
  Future<void> loadNotifications({String? token}) async {
    calls.add('loadNotifications');
  }

  @override
  Future<void> loadAssignments({required String userId, String? token}) async {
    calls.add('loadAssignments');
  }
}

class _TrackingSectorNotifier extends SectorNotifier {
  final List<String> calls = [];

  _TrackingSectorNotifier(super.service);

  @override
  Future<void> loadSectors({String? token}) async {
    calls.add('loadSectors');
  }
}

void main() {
  late MockAlertService mockAlertService;
  late MockSectorService mockSectorService;
  late _TrackingAlertNotifier alertNotifier;
  late _TrackingSectorNotifier sectorNotifier;

  setUp(() {
    mockAlertService = MockAlertService();
    mockSectorService = MockSectorService();
    alertNotifier = _TrackingAlertNotifier(mockAlertService);
    sectorNotifier = _TrackingSectorNotifier(mockSectorService);
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        alertProvider.overrideWith((_) => alertNotifier),
        sectorProvider.overrideWith((_) => sectorNotifier),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    );
  }

  testWidgets('não chama loads ao inicializar (delegado ao HomeScreen)',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(alertNotifier.calls, isEmpty);
    expect(sectorNotifier.calls, isEmpty);
  });

  testWidgets('botão de refresh chama loadNotifications e loadAssignments',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    alertNotifier.calls.clear();

    await tester.tap(find.byIcon(LucideIcons.refreshCw));
    await tester.pump();

    expect(alertNotifier.calls, containsAll(['loadNotifications', 'loadAssignments']));
  });

  testWidgets('botão de refresh chama loadSectors', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    sectorNotifier.calls.clear();

    await tester.tap(find.byIcon(LucideIcons.refreshCw));
    await tester.pump();

    expect(sectorNotifier.calls, contains('loadSectors'));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';

class MockAlertService extends Mock implements AlertService {}

class _TrackingAlertNotifier extends AlertNotifier {
  final List<String> calls = [];

  _TrackingAlertNotifier(super.service) : super();

  @override
  Future<void> loadNotifications({String? token}) async {
    calls.add('loadNotifications');
  }

  @override
  Future<void> loadAssignments({String? token}) async {
    calls.add('loadAssignments');
  }
}

void main() {
  late MockAlertService mockService;
  late _TrackingAlertNotifier notifier;

  setUp(() {
    mockService = MockAlertService();
    notifier = _TrackingAlertNotifier(mockService);
  });

  Widget buildSubject() {
    return ProviderScope(
      overrides: [
        alertProvider.overrideWith((_) => notifier),
      ],
      child: const MaterialApp(home: DashboardScreen()),
    );
  }

  testWidgets('chama loadNotifications e loadAssignments ao inicializar',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(); // processa o addPostFrameCallback

    expect(notifier.calls, containsAll(['loadNotifications', 'loadAssignments']));
  });

  testWidgets('botão de refresh chama loadNotifications e loadAssignments',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();

    notifier.calls.clear();

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(notifier.calls, containsAll(['loadNotifications', 'loadAssignments']));
  });
}

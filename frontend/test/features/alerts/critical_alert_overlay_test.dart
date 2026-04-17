import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/alerts/widgets/critical_alert_overlay.dart';

class MockAlertService extends Mock implements AlertService {}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service);

  bool acknowledgeWasCalled = false;

  @override
  Future<void> acknowledge({required String assignmentId, String? token}) async {
    acknowledgeWasCalled = true;
  }
}

AssignmentModel _makeAssignment({
  AlertLevel level = AlertLevel.critical,
  AssignmentStatus status = AssignmentStatus.pending,
  String? title,
  String? message,
}) =>
    AssignmentModel(
      id: 'assign-1',
      userId: 'user-1',
      notificationId: 'notif-1',
      notificationTitle: title,
      notificationMessage: message,
      notificationLevel: level,
      status: status,
      createdAt: DateTime(2026, 4, 16),
    );

Widget _buildSubject(AssignmentModel assignment) {
  return ProviderScope(
    overrides: [
      alertProvider.overrideWith((_) => _StubAlertNotifier(MockAlertService())),
    ],
    child: MaterialApp(
      home: CriticalAlertOverlay(assignment: assignment),
    ),
  );
}

void main() {
  group('CriticalAlertOverlay', () {
    testWidgets('exibe título da notificação', (tester) async {
      await tester.pumpWidget(
        _buildSubject(_makeAssignment(title: 'Servidor crítico')),
      );
      expect(find.text('Servidor crítico'), findsWidgets);
    });

    testWidgets('exibe fallback quando título ausente', (tester) async {
      await tester.pumpWidget(_buildSubject(_makeAssignment()));
      expect(find.text('Notificação Crítica'), findsWidgets);
    });

    testWidgets('exibe mensagem quando presente', (tester) async {
      await tester.pumpWidget(
        _buildSubject(_makeAssignment(message: 'Sistema comprometido.')),
      );
      expect(find.text('Sistema comprometido.'), findsOneWidget);
    });

    testWidgets('exibe botão Confirmar ciência', (tester) async {
      await tester.pumpWidget(_buildSubject(_makeAssignment()));
      expect(find.text('Confirmar ciência'), findsOneWidget);
    });

    testWidgets('back button é bloqueado via PopScope', (tester) async {
      await tester.pumpWidget(_buildSubject(_makeAssignment()));
      expect(find.byType(PopScope), findsOneWidget);
    });

    testWidgets('botão confirmar chama acknowledge e fecha overlay', (tester) async {
      late _StubAlertNotifier notifier;
      final assignment = _makeAssignment();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            alertProvider.overrideWith((ref) {
              notifier = _StubAlertNotifier(MockAlertService());
              return notifier;
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CriticalAlertOverlay(assignment: assignment),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmar ciência'));
      await tester.pumpAndSettle();

      expect(notifier.acknowledgeWasCalled, isTrue);
    });
  });
}

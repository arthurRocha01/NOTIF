import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alert_details_screen.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

class _StubAlertNotifier extends AlertNotifier {
  _StubAlertNotifier(super.service);

  @override
  Future<void> acknowledge({required String assignmentId, String? token}) async {}
}

AssignmentModel _makeAssignment({
  String? title,
  String? message,
  AssignmentStatus status = AssignmentStatus.pending,
  AlertLevel level = AlertLevel.high,
}) =>
    AssignmentModel(
      id: 'assign-1',
      userId: 'user-1',
      notificationId: 'notif-1',
      notificationTitle: title,
      notificationMessage: message,
      notificationLevel: level,
      status: status,
      createdAt: DateTime(2026, 4, 12),
      dueAt: DateTime(2026, 4, 12, 23, 0),
    );

Widget buildSubject(AssignmentModel assignment) {
  return ProviderScope(
    overrides: [
      alertProvider.overrideWith(
          (_) => _StubAlertNotifier(MockAlertService())),
    ],
    child: MaterialApp(
      home: AlertDetailsScreen(assignment: assignment),
    ),
  );
}

void main() {
  group('AlertDetailsScreen', () {
    testWidgets('exibe título da notificação', (tester) async {
      await tester.pumpWidget(
          buildSubject(_makeAssignment(title: 'Manutenção preventiva')));
      await tester.pump();

      expect(find.text('Manutenção preventiva'), findsWidgets);
    });

    testWidgets('exibe fallback quando título ausente', (tester) async {
      await tester.pumpWidget(buildSubject(_makeAssignment()));
      await tester.pump();

      expect(find.text('Notificação'), findsWidgets);
    });

    testWidgets('exibe mensagem quando presente', (tester) async {
      await tester.pumpWidget(buildSubject(
          _makeAssignment(message: 'O servidor ficará indisponível.')));
      await tester.pump();

      expect(find.text('O servidor ficará indisponível.'), findsOneWidget);
    });

    testWidgets('exibe botão de confirmação para assignment crítico pendente',
        (tester) async {
      await tester.pumpWidget(buildSubject(_makeAssignment(
        level: AlertLevel.critical,
        status: AssignmentStatus.pending,
      )));
      await tester.pump();

      expect(find.text('Confirmar ciência'), findsOneWidget);
    });

    testWidgets('não exibe botão de confirmação para assignment confirmado',
        (tester) async {
      await tester.pumpWidget(buildSubject(_makeAssignment(
        level: AlertLevel.critical,
        status: AssignmentStatus.acknowledged,
      )));
      await tester.pump();

      expect(find.text('Confirmar ciência'), findsNothing);
    });
  });
}

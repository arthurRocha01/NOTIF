import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

class MockAlertService extends Mock implements AlertService {}

AlertModel _makeNotification({
  String id = 'notif-1',
  AlertLevel level = AlertLevel.high,
}) =>
    AlertModel(
      id: id,
      title: 'Teste',
      message: 'Mensagem',
      level: level,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      createdAt: DateTime(2026, 4, 9),
    );

AssignmentModel _makeAssignment({
  String id = 'assign-1',
  AlertLevel level = AlertLevel.high,
  AssignmentStatus status = AssignmentStatus.pending,
}) =>
    AssignmentModel(
      id: id,
      userId: 'user-1',
      notificationId: 'notif-1',
      notificationLevel: level,
      status: status,
      createdAt: DateTime(2026, 4, 9),
    );

ProviderContainer _makeContainer(MockAlertService mock) {
  return ProviderContainer(
    overrides: [
      alertServiceProvider.overrideWithValue(mock),
    ],
  );
}

void main() {
  late MockAlertService mockService;

  setUpAll(() {
    registerFallbackValue(AlertLevel.low);
  });

  setUp(() {
    mockService = MockAlertService();
  });

  group('AlertNotifier.loadNotifications', () {
    test('carrega notificações e atualiza estado', () async {
      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeNotification()]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      final state = container.read(alertProvider);
      expect(state.notifications, hasLength(1));
      expect(state.notifications.first.id, equals('notif-1'));
      expect(state.isLoadingNotifications, isFalse);
    });

    test('isLoadingNotifications fica false após erro', () async {
      when(() => mockService.getNotifications(token: any(named: 'token')))
          .thenThrow(AlertServiceException('Erro'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadNotifications(token: 'tok');

      expect(container.read(alertProvider).isLoadingNotifications, isFalse);
    });
  });

  group('AlertNotifier.loadAssignments', () {
    test('carrega assignments e atualiza estado', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeAssignment()]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');

      final state = container.read(alertProvider);
      expect(state.assignments, hasLength(1));
      expect(state.assignments.first.id, equals('assign-1'));
      expect(state.isLoadingAssignments, isFalse);
    });
  });

  group('AlertNotifier.isBlocked', () {
    test('isBlocked true quando há assignment CRITICAL não acknowledged', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeAssignment(
                  level: AlertLevel.critical,
                  status: AssignmentStatus.pending,
                ),
              ]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');

      expect(container.read(alertProvider).isBlocked, isTrue);
    });

    test('isBlocked false quando CRITICAL está acknowledged', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeAssignment(
                  level: AlertLevel.critical,
                  status: AssignmentStatus.acknowledged,
                ),
              ]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');

      expect(container.read(alertProvider).isBlocked, isFalse);
    });

    test('isBlocked false quando não há assignments críticos', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeAssignment(
                  level: AlertLevel.high,
                  status: AssignmentStatus.pending,
                ),
              ]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');

      expect(container.read(alertProvider).isBlocked, isFalse);
    });
  });

  group('AlertNotifier.acknowledge', () {
    test('atualiza assignment local para ACKNOWLEDGED após sucesso', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeAssignment()]);
      when(() => mockService.acknowledge(
                assignmentId: any(named: 'assignmentId'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');
      await container
          .read(alertProvider.notifier)
          .acknowledge(assignmentId: 'assign-1', token: 'tok');

      final assignment = container
          .read(alertProvider)
          .assignments
          .firstWhere((a) => a.id == 'assign-1');

      expect(assignment.status, equals(AssignmentStatus.acknowledged));
    });
  });

  group('AlertNotifier.markAllPendingAsViewed', () {
    test('chama markAsViewed para cada assignment com status PENDING', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeAssignment(id: 'a1', status: AssignmentStatus.pending),
                _makeAssignment(id: 'a2', status: AssignmentStatus.pending),
                _makeAssignment(id: 'a3', status: AssignmentStatus.viewed),
              ]);
      when(() => mockService.markAsViewed(
                assignmentId: any(named: 'assignmentId'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');
      await container
          .read(alertProvider.notifier)
          .markAllPendingAsViewed(token: 'tok');

      verify(() => mockService.markAsViewed(
            assignmentId: 'a1',
            token: any(named: 'token'),
          )).called(1);
      verify(() => mockService.markAsViewed(
            assignmentId: 'a2',
            token: any(named: 'token'),
          )).called(1);
      verifyNever(() => mockService.markAsViewed(
            assignmentId: 'a3',
            token: any(named: 'token'),
          ));
    });

    test('não chama service quando não há assignments PENDING', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [
                _makeAssignment(id: 'a1', status: AssignmentStatus.viewed),
              ]);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');
      await container
          .read(alertProvider.notifier)
          .markAllPendingAsViewed(token: 'tok');

      verifyNever(() => mockService.markAsViewed(
            assignmentId: any(named: 'assignmentId'),
            token: any(named: 'token'),
          ));
    });
  });

  group('AlertNotifier.syncDeliveries', () {
    test('chama service.syncDeliveries sem alterar estado de assignments', () async {
      when(() => mockService.getMyAssignments(token: any(named: 'token')))
          .thenAnswer((_) async => [_makeAssignment()]);
      when(() => mockService.syncDeliveries(
                userId: any(named: 'userId'),
                token: any(named: 'token'),
              ))
          .thenAnswer((_) async {});

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      await container
          .read(alertProvider.notifier)
          .loadAssignments(token: 'tok');
      await container
          .read(alertProvider.notifier)
          .syncDeliveries(userId: 'user-1', token: 'tok');

      verify(() => mockService.syncDeliveries(
            userId: 'user-1',
            token: any(named: 'token'),
          )).called(1);
      expect(container.read(alertProvider).assignments, hasLength(1));
    });
  });

  group('AlertNotifier.createNotification', () {
    test('cria notificação e a adiciona ao estado', () async {
      final newNotif = _makeNotification(id: 'notif-new');

      when(() => mockService.createNotification(
                token: any(named: 'token'),
                title: any(named: 'title'),
                message: any(named: 'message'),
                level: any(named: 'level'),
                slaMinutes: any(named: 'slaMinutes'),
                requiresAcknowledgment: any(named: 'requiresAcknowledgment'),
                sectorId: any(named: 'sectorId'),
              ))
          .thenAnswer((_) async => newNotif);

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      final ok = await container.read(alertProvider.notifier).createNotification(
            token: 'tok',
            title: 'Novo',
            message: 'Mensagem',
            level: AlertLevel.high,
            slaMinutes: 60,
            requiresAcknowledgment: false,
          );

      expect(ok, isTrue);
      expect(
        container.read(alertProvider).notifications.any((n) => n.id == 'notif-new'),
        isTrue,
      );
    });

    test('retorna false em falha', () async {
      when(() => mockService.createNotification(
                token: any(named: 'token'),
                title: any(named: 'title'),
                message: any(named: 'message'),
                level: any(named: 'level'),
                slaMinutes: any(named: 'slaMinutes'),
                requiresAcknowledgment: any(named: 'requiresAcknowledgment'),
                sectorId: any(named: 'sectorId'),
              ))
          .thenThrow(AlertServiceException('Erro'));

      final container = _makeContainer(mockService);
      addTearDown(container.dispose);

      final ok = await container.read(alertProvider.notifier).createNotification(
            token: 'tok',
            title: 'Novo',
            message: 'Mensagem',
            level: AlertLevel.high,
            slaMinutes: 60,
            requiresAcknowledgment: false,
          );

      expect(ok, isFalse);
    });
  });
}

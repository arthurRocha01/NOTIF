import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertService extends Mock implements AlertService {}

ProviderContainer _makeContainer(AlertState alertState) {
  final mock = MockAlertService();
  return ProviderContainer(
    overrides: [
      alertProvider.overrideWith((_) => _FixedAlertNotifier(mock, alertState)),
    ],
  );
}

class _FixedAlertNotifier extends AlertNotifier {
  _FixedAlertNotifier(super.service, AlertState fixedState) {
    state = fixedState;
  }
}

AlertModel _makeNotif({required String id, String? sectorId}) => AlertModel(
      id: id,
      title: 'T',
      message: 'M',
      level: AlertLevel.high,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      targetSectorId: sectorId,
      createdAt: DateTime(2026, 4, 10),
    );

AssignmentModel _makeAssign({
  required String id,
  required String notificationId,
  AssignmentStatus status = AssignmentStatus.pending,
}) =>
    AssignmentModel(
      id: id,
      userId: 'user-1',
      notificationId: notificationId,
      notificationLevel: AlertLevel.high,
      status: status,
      createdAt: DateTime(2026, 4, 10),
    );

void main() {
  group('dashboardProvider', () {
    test('retorna DashboardData vazio quando não há dados', () {
      final container = _makeContainer(const AlertState());
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      expect(data.topSector, equals('Nenhum'));
      expect(data.topSectorRate, equals(0.0));
      expect(data.sectorRates, isEmpty);
      expect(data.attentionSectors, isEmpty);
    });

    test('calcula taxa de setor como acknowledged / total', () {
      final container = _makeContainer(AlertState(
        notifications: [_makeNotif(id: 'n1', sectorId: 'setor-ti')],
        assignments: [
          _makeAssign(
              id: 'a1',
              notificationId: 'n1',
              status: AssignmentStatus.acknowledged),
          _makeAssign(
              id: 'a2',
              notificationId: 'n1',
              status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      expect(data.sectorRates['setor-ti'], closeTo(0.5, 0.001));
    });

    test('topSector é o setor com maior taxa', () {
      final container = _makeContainer(AlertState(
        notifications: [
          _makeNotif(id: 'n1', sectorId: 'ti'),
          _makeNotif(id: 'n2', sectorId: 'rh'),
        ],
        assignments: [
          _makeAssign(
              id: 'a1',
              notificationId: 'n1',
              status: AssignmentStatus.acknowledged),
          _makeAssign(
              id: 'a2',
              notificationId: 'n2',
              status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      expect(data.topSector, equals('ti'));
      expect(data.topSectorRate, closeTo(1.0, 0.001));
    });

    test('attentionSectors contém setores com taxa abaixo de 60%', () {
      final container = _makeContainer(AlertState(
        notifications: [
          _makeNotif(id: 'n1', sectorId: 'ti'),
          _makeNotif(id: 'n2', sectorId: 'rh'),
        ],
        assignments: [
          _makeAssign(
              id: 'a1',
              notificationId: 'n1',
              status: AssignmentStatus.acknowledged),
          _makeAssign(
              id: 'a2',
              notificationId: 'n2',
              status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      expect(data.attentionSectors, contains('rh'));
      expect(data.attentionSectors, isNot(contains('ti')));
    });

    test('notificações globais (sectorId null) são ignoradas no cálculo por setor', () {
      final container = _makeContainer(AlertState(
        notifications: [_makeNotif(id: 'n1', sectorId: null)],
        assignments: [
          _makeAssign(
              id: 'a1',
              notificationId: 'n1',
              status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      expect(data.sectorRates, isEmpty);
      expect(data.topSector, equals('Nenhum'));
    });

    test('setor com taxa exatamente 60% não entra em attentionSectors', () {
      final container = _makeContainer(AlertState(
        notifications: [
          _makeNotif(id: 'n1', sectorId: 'ops'),
          _makeNotif(id: 'n2', sectorId: 'ops'),
          _makeNotif(id: 'n3', sectorId: 'ops'),
          _makeNotif(id: 'n4', sectorId: 'ops'),
          _makeNotif(id: 'n5', sectorId: 'ops'),
        ],
        assignments: [
          _makeAssign(id: 'a1', notificationId: 'n1', status: AssignmentStatus.acknowledged),
          _makeAssign(id: 'a2', notificationId: 'n2', status: AssignmentStatus.acknowledged),
          _makeAssign(id: 'a3', notificationId: 'n3', status: AssignmentStatus.acknowledged),
          _makeAssign(id: 'a4', notificationId: 'n4', status: AssignmentStatus.pending),
          _makeAssign(id: 'a5', notificationId: 'n5', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(container.dispose);

      final data = container.read(dashboardProvider);
      // 3/5 = 60% → não deve estar em attentionSectors (< 60%)
      expect(data.sectorRates['ops'], closeTo(0.6, 0.001));
      expect(data.attentionSectors, isNot(contains('ops')));
    });
  });
}

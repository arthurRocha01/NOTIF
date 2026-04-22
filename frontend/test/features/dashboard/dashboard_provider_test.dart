import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_filter_provider.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:notif_app/features/sectors/models/sector_model.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertService extends Mock implements AlertService {}
class MockSectorService extends Mock implements SectorService {}

// Helpers ─────────────────────────────────────────────────────────────────────

AlertModel _notif({required String id, String? sectorId}) => AlertModel(
      id: id,
      title: 'T',
      message: 'M',
      level: AlertLevel.medium,
      slaMinutes: 60,
      requiresAcknowledgment: false,
      targetSectorId: sectorId,
      createdAt: DateTime(2026, 4, 10),
    );

AssignmentModel _assign({
  required String id,
  required String notifId,
  AssignmentStatus status = AssignmentStatus.pending,
  DateTime? createdAt,
}) =>
    AssignmentModel(
      id: id,
      userId: 'u1',
      notificationId: notifId,
      notificationLevel: AlertLevel.medium,
      status: status,
      createdAt: createdAt ?? DateTime(2026, 4, 10),
    );

SectorModel _sector(String id, String name) => SectorModel(id: id, name: name);

// Container factory ───────────────────────────────────────────────────────────

ProviderContainer _make({
  required AlertState alertState,
  List<SectorModel> sectors = const [],
  DashboardFilter filter = const DashboardFilter(),
}) {
  final mockAlert = MockAlertService();
  final mockSector = MockSectorService();
  return ProviderContainer(
    overrides: [
      alertProvider.overrideWith((_) => _FixedAlertNotifier(mockAlert, alertState)),
      sectorProvider.overrideWith((_) => _FixedSectorNotifier(mockSector, sectors)),
      dashboardFilterProvider.overrideWith((_) => DashboardFilterNotifier()..state = filter),
    ],
  );
}

class _FixedAlertNotifier extends AlertNotifier {
  _FixedAlertNotifier(super.service, AlertState s) { state = s; }
}

class _FixedSectorNotifier extends SectorNotifier {
  _FixedSectorNotifier(super.service, List<SectorModel> sectors) {
    state = SectorState(sectors: sectors);
  }
}

// Tests ───────────────────────────────────────────────────────────────────────

void main() {
  group('dashboardProvider — estado vazio', () {
    test('retorna zeros quando não há dados', () {
      final c = _make(alertState: const AlertState());
      addTearDown(c.dispose);

      final d = c.read(dashboardProvider);
      expect(d.topSector, 'Nenhum');
      expect(d.topSectorRate, 0.0);
      expect(d.sectorRates, isEmpty);
      expect(d.attentionSectors, isEmpty);
      expect(d.totalAssignments, 0);
      expect(d.totalAcknowledged, 0);
      expect(d.totalPending, 0);
      expect(d.totalCritical, 0);
    });
  });

  group('dashboardProvider — KPIs', () {
    test('conta totalAssignments corretamente', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: 's1')],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.pending),
          _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.acknowledged),
          _assign(id: 'a3', notifId: 'n1', status: AssignmentStatus.viewed),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalAssignments, 3);
    });

    test('conta totalAcknowledged corretamente', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: 's1')],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged),
          _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalAcknowledged, 1);
    });

    test('conta totalPending corretamente', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: 's1')],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.pending),
          _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.pending),
          _assign(id: 'a3', notifId: 'n1', status: AssignmentStatus.acknowledged),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalPending, 2);
    });

    test('conta totalCritical corretamente', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: 's1')],
        assignments: [
          AssignmentModel(
            id: 'a1', userId: 'u1', notificationId: 'n1',
            notificationLevel: AlertLevel.critical,
            status: AssignmentStatus.pending,
            createdAt: DateTime(2026, 4, 10),
          ),
          _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalCritical, 1);
    });
  });

  group('dashboardProvider — taxas por setor', () {
    test('calcula taxa acknowledged/total por setor', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: 'ti')],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged),
          _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).sectorRates['ti'], closeTo(0.5, 0.001));
    });

    test('topSector é o setor com maior taxa', () {
      final c = _make(alertState: AlertState(
        notifications: [
          _notif(id: 'n1', sectorId: 'ti'),
          _notif(id: 'n2', sectorId: 'rh'),
        ],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged),
          _assign(id: 'a2', notifId: 'n2', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).topSector, 'ti');
      expect(c.read(dashboardProvider).topSectorRate, closeTo(1.0, 0.001));
    });

    test('notificações globais são ignoradas no cálculo por setor', () {
      final c = _make(alertState: AlertState(
        notifications: [_notif(id: 'n1', sectorId: null)],
        assignments: [_assign(id: 'a1', notifId: 'n1')],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).sectorRates, isEmpty);
    });

    test('setor com taxa exatamente 60% não entra em attentionSectors', () {
      final c = _make(alertState: AlertState(
        notifications: [
          _notif(id: 'n1', sectorId: 'ops'),
          _notif(id: 'n2', sectorId: 'ops'),
          _notif(id: 'n3', sectorId: 'ops'),
          _notif(id: 'n4', sectorId: 'ops'),
          _notif(id: 'n5', sectorId: 'ops'),
        ],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged),
          _assign(id: 'a2', notifId: 'n2', status: AssignmentStatus.acknowledged),
          _assign(id: 'a3', notifId: 'n3', status: AssignmentStatus.acknowledged),
          _assign(id: 'a4', notifId: 'n4', status: AssignmentStatus.pending),
          _assign(id: 'a5', notifId: 'n5', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).sectorRates['ops'], closeTo(0.6, 0.001));
      expect(c.read(dashboardProvider).attentionSectors.map((a) => a.id), isNot(contains('ops')));
    });
  });

  group('dashboardProvider — attentionSectors com detalhes', () {
    test('attentionSector expõe taxa e contagem de pendentes', () {
      final c = _make(alertState: AlertState(
        notifications: [
          _notif(id: 'n1', sectorId: 'rh'),
          _notif(id: 'n2', sectorId: 'rh'),
        ],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.pending),
          _assign(id: 'a2', notifId: 'n2', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      final attention = c.read(dashboardProvider).attentionSectors;
      expect(attention, hasLength(1));
      expect(attention.first.id, 'rh');
      expect(attention.first.rate, closeTo(0.0, 0.001));
      expect(attention.first.pendingCount, 2);
    });

    test('attentionSectors ordenados por taxa crescente (pior primeiro)', () {
      final c = _make(alertState: AlertState(
        notifications: [
          _notif(id: 'n1', sectorId: 'a'),
          _notif(id: 'n2', sectorId: 'a'),
          _notif(id: 'n3', sectorId: 'b'),
          _notif(id: 'n4', sectorId: 'b'),
          _notif(id: 'n5', sectorId: 'b'),
          _notif(id: 'n6', sectorId: 'b'),
        ],
        assignments: [
          _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged), // a=50%
          _assign(id: 'a2', notifId: 'n2', status: AssignmentStatus.pending),
          _assign(id: 'a3', notifId: 'n3', status: AssignmentStatus.pending), // b=0%
          _assign(id: 'a4', notifId: 'n4', status: AssignmentStatus.pending),
          _assign(id: 'a5', notifId: 'n5', status: AssignmentStatus.pending),
          _assign(id: 'a6', notifId: 'n6', status: AssignmentStatus.pending),
        ],
      ));
      addTearDown(c.dispose);
      final ids = c.read(dashboardProvider).attentionSectors.map((a) => a.id).toList();
      expect(ids.first, 'b'); // 0% vem antes de 50%
    });
  });

  group('dashboardProvider — resolução de nome via sectorProvider', () {
    test('usa nome do setor quando disponível', () {
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'uuid-ti')],
          assignments: [_assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged)],
        ),
        sectors: [_sector('uuid-ti', 'TI')],
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).topSector, 'TI');
      expect(c.read(dashboardProvider).sectorRates.containsKey('TI'), isTrue);
    });

    test('usa id como fallback quando setor não está na lista', () {
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'uuid-desconhecido')],
          assignments: [_assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.acknowledged)],
        ),
        sectors: [],
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).topSector, 'uuid-desconhecido');
    });
  });

  group('dashboardProvider — filtro de período', () {
    test('filtro week exclui assignments com mais de 7 dias', () {
      final now = DateTime.now();
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'ti')],
          assignments: [
            _assign(id: 'a1', notifId: 'n1',
                status: AssignmentStatus.acknowledged,
                createdAt: now.subtract(const Duration(days: 3))),
            _assign(id: 'a2', notifId: 'n1',
                status: AssignmentStatus.pending,
                createdAt: now.subtract(const Duration(days: 10))), // fora do filtro
          ],
        ),
        filter: const DashboardFilter(period: DashboardPeriod.week),
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalAssignments, 1);
      expect(c.read(dashboardProvider).totalAcknowledged, 1);
    });

    test('filtro month exclui assignments com mais de 30 dias', () {
      final now = DateTime.now();
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'ti')],
          assignments: [
            _assign(id: 'a1', notifId: 'n1',
                status: AssignmentStatus.pending,
                createdAt: now.subtract(const Duration(days: 15))),
            _assign(id: 'a2', notifId: 'n1',
                status: AssignmentStatus.pending,
                createdAt: now.subtract(const Duration(days: 35))), // fora
          ],
        ),
        filter: const DashboardFilter(period: DashboardPeriod.month),
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalAssignments, 1);
    });

    test('filtro all não exclui nenhum assignment', () {
      final now = DateTime.now();
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'ti')],
          assignments: [
            _assign(id: 'a1', notifId: 'n1',
                createdAt: now.subtract(const Duration(days: 365))),
            _assign(id: 'a2', notifId: 'n1',
                createdAt: now.subtract(const Duration(days: 1))),
          ],
        ),
        filter: const DashboardFilter(period: DashboardPeriod.all),
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).totalAssignments, 2);
    });
  });

  group('dashboardProvider — selectedSectorBreakdown', () {
    test('retorna null quando nenhum setor selecionado', () {
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'ti')],
          assignments: [_assign(id: 'a1', notifId: 'n1')],
        ),
      );
      addTearDown(c.dispose);
      expect(c.read(dashboardProvider).selectedSectorBreakdown, isNull);
    });

    test('retorna breakdown correto para setor selecionado', () {
      final c = _make(
        alertState: AlertState(
          notifications: [_notif(id: 'n1', sectorId: 'ti')],
          assignments: [
            _assign(id: 'a1', notifId: 'n1', status: AssignmentStatus.pending),
            _assign(id: 'a2', notifId: 'n1', status: AssignmentStatus.viewed),
            _assign(id: 'a3', notifId: 'n1', status: AssignmentStatus.acknowledged),
            _assign(id: 'a4', notifId: 'n1', status: AssignmentStatus.overdue),
          ],
        ),
        filter: const DashboardFilter(selectedSectorId: 'ti'),
      );
      addTearDown(c.dispose);
      final bd = c.read(dashboardProvider).selectedSectorBreakdown!;
      expect(bd.pending, 1);
      expect(bd.viewed, 1);
      expect(bd.acknowledged, 1);
      expect(bd.overdue, 1);
    });
  });
}

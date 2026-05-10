import 'package:flutter_test/flutter_test.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/dashboard/services/dashboard_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import '../../helpers/alert_test_helpers.dart';

void main() {
  final auth = AuthService();
  final dashboard = DashboardService();

  setUpAll(() async {
    await loginAsSupervisor(auth);
  });

  group('DashboardService.getSummary — sem filtros', () {
    late DashboardData data;

    setUpAll(() async {
      data = await dashboard.getSummary();
    });

    test('campos numéricos são não-negativos', () {
      expect(data.totalNotifications, greaterThanOrEqualTo(0));
      expect(data.totalAcknowledged, greaterThanOrEqualTo(0));
      expect(data.totalPending, greaterThanOrEqualTo(0));
      expect(data.totalCritical, greaterThanOrEqualTo(0));
    });

    test('topSector não é vazio e topSectorRate está entre 0 e 1', () {
      expect(data.topSector, isNotEmpty);
      expect(data.topSectorRate, greaterThanOrEqualTo(0.0));
      expect(data.topSectorRate, lessThanOrEqualTo(1.0));
    });

    test('attentionSectors contêm apenas setores com taxa < 0.6', () {
      for (final s in data.attentionSectors) {
        expect(
          s.rate,
          lessThan(0.6),
          reason: 'Setor ${s.name} tem taxa ${s.rate} mas deveria ser < 0.6',
        );
      }
    });

    test('selectedSectorBreakdown é null sem sectorId', () {
      expect(data.selectedSectorBreakdown, isNull);
    });
  });

  group('DashboardService.getSummary — filtro de período', () {
    test('period=week retorna subset de period=all', () async {
      final all = await dashboard.getSummary();
      final week = await dashboard.getSummary(period: 'week');
      expect(
        week.totalNotifications,
        lessThanOrEqualTo(all.totalNotifications),
      );
    });
  });

  group('DashboardService.getSummary — filtro de setor', () {
    test('selectedSectorBreakdown preenchido e com campos não-negativos', () async {
      final sectors = await ApiClient.get('/sectors') as List<dynamic>;
      if (sectors.isEmpty) return;
      final sectorId = sectors.first['id'] as String;

      final data = await dashboard.getSummary(sectorId: sectorId);
      final bd = data.selectedSectorBreakdown!;

      expect(bd.pending, greaterThanOrEqualTo(0));
      expect(bd.viewed, greaterThanOrEqualTo(0));
      expect(bd.acknowledged, greaterThanOrEqualTo(0));
      expect(bd.overdue, greaterThanOrEqualTo(0));
    });
  });

  group('DashboardService.getSummary — sem autenticação', () {
    tearDown(() async {
      await loginAsSupervisor(auth);
    });

    test('lança ApiException com status 401', () async {
      ApiClient.clearToken();
      await expectLater(
        dashboard.getSummary(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_filter_provider.dart';

void main() {
  ProviderContainer makeContainer() => ProviderContainer();

  group('DashboardFilterNotifier — estado inicial', () {
    test('período inicial é all', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      expect(c.read(dashboardFilterProvider).period, DashboardPeriod.all);
    });

    test('setor inicial é null (todos)', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      expect(c.read(dashboardFilterProvider).selectedSectorId, isNull);
    });
  });

  group('DashboardFilterNotifier — mudança de período', () {
    test('setPeriod atualiza período para week', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setPeriod(DashboardPeriod.week);
      expect(c.read(dashboardFilterProvider).period, DashboardPeriod.week);
    });

    test('setPeriod atualiza período para month', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setPeriod(DashboardPeriod.month);
      expect(c.read(dashboardFilterProvider).period, DashboardPeriod.month);
    });

    test('setPeriod mantém setor selecionado', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setSector('setor-ti');
      c.read(dashboardFilterProvider.notifier).setPeriod(DashboardPeriod.week);
      expect(c.read(dashboardFilterProvider).selectedSectorId, 'setor-ti');
    });
  });

  group('DashboardFilterNotifier — seleção de setor', () {
    test('setSector atualiza setor selecionado', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setSector('setor-rh');
      expect(c.read(dashboardFilterProvider).selectedSectorId, 'setor-rh');
    });

    test('setSector com null limpa seleção (todos os setores)', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setSector('setor-ti');
      c.read(dashboardFilterProvider.notifier).setSector(null);
      expect(c.read(dashboardFilterProvider).selectedSectorId, isNull);
    });

    test('setSector mantém período atual', () {
      final c = makeContainer();
      addTearDown(c.dispose);
      c.read(dashboardFilterProvider.notifier).setPeriod(DashboardPeriod.month);
      c.read(dashboardFilterProvider.notifier).setSector('setor-ops');
      expect(c.read(dashboardFilterProvider).period, DashboardPeriod.month);
    });
  });

  group('DashboardFilter — label de período', () {
    test('all retorna "Todos"', () {
      const f = DashboardFilter(period: DashboardPeriod.all);
      expect(f.periodLabel, 'Todos');
    });

    test('week retorna "7 dias"', () {
      const f = DashboardFilter(period: DashboardPeriod.week);
      expect(f.periodLabel, '7 dias');
    });

    test('month retorna "30 dias"', () {
      const f = DashboardFilter(period: DashboardPeriod.month);
      expect(f.periodLabel, '30 dias');
    });
  });
}

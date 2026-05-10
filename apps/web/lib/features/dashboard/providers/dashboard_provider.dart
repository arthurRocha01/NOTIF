import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/dashboard/providers/dashboard_filter_provider.dart';
import 'package:notif_app/features/dashboard/services/dashboard_service.dart';

export 'package:notif_app/features/dashboard/services/dashboard_service.dart'
    show DashboardData, AttentionSector, SectorStatusBreakdown;

final dashboardProvider =
    AsyncNotifierProvider<_DashboardNotifier, DashboardData>(
  _DashboardNotifier.new,
);

class _DashboardNotifier extends AsyncNotifier<DashboardData> {
  @override
  Future<DashboardData> build() async {
    final filter = ref.watch(dashboardFilterProvider);
    return DashboardService().getSummary(
      period: _periodParam(filter.period),
      sectorId: filter.selectedSectorId,
    );
  }

  String? _periodParam(DashboardPeriod period) => switch (period) {
        DashboardPeriod.week => 'week',
        DashboardPeriod.month => 'month',
        DashboardPeriod.all => null,
      };
}

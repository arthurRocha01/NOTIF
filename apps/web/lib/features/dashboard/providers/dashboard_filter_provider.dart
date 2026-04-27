import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardPeriod { week, month, all }

class DashboardFilter {
  final DashboardPeriod period;
  final String? selectedSectorId;

  const DashboardFilter({
    this.period = DashboardPeriod.all,
    this.selectedSectorId,
  });

  String get periodLabel => switch (period) {
        DashboardPeriod.week => '7 dias',
        DashboardPeriod.month => '30 dias',
        DashboardPeriod.all => 'Todos',
      };

  DashboardFilter copyWith({
    DashboardPeriod? period,
    Object? selectedSectorId = _sentinel,
  }) {
    return DashboardFilter(
      period: period ?? this.period,
      selectedSectorId: selectedSectorId == _sentinel
          ? this.selectedSectorId
          : selectedSectorId as String?,
    );
  }
}

// Sentinel para distinguir null explícito de "não alterado"
const Object _sentinel = Object();

class DashboardFilterNotifier extends StateNotifier<DashboardFilter> {
  DashboardFilterNotifier() : super(const DashboardFilter());

  void setPeriod(DashboardPeriod period) {
    state = state.copyWith(period: period);
  }

  void setSector(String? sectorId) {
    state = state.copyWith(selectedSectorId: sectorId);
  }
}

final dashboardFilterProvider =
    StateNotifierProvider<DashboardFilterNotifier, DashboardFilter>(
  (_) => DashboardFilterNotifier(),
);

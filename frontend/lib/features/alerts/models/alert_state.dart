import '../models/alert_model.dart';

class AlertState {
  final List<AlertModel> activeAlerts;
  final List<AlertModel> history;
  final bool isLoadingActive;
  final bool isLoadingHistory;

  const AlertState({
    this.activeAlerts = const [],
    this.history = const [],
    this.isLoadingActive = false,
    this.isLoadingHistory = false,
  });

  AlertState copyWith({
    List<AlertModel>? activeAlerts,
    List<AlertModel>? history,
    bool? isLoadingActive,
    bool? isLoadingHistory,
  }) {
    return AlertState(
      activeAlerts: activeAlerts ?? this.activeAlerts,
      history: history ?? this.history,
      isLoadingActive: isLoadingActive ?? this.isLoadingActive,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }
}
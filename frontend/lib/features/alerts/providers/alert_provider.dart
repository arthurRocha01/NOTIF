import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';

final alertProvider =
    StateNotifierProvider<AlertNotifier, List<AlertModel>>((ref) {
  return AlertNotifier();
});

class AlertNotifier extends StateNotifier<List<AlertModel>> {
  AlertNotifier() : super([]);

  bool isLoadingActive = false;
  bool isLoadingHistory = false;
  String? errorMessage;

  List<AlertModel> get activeAlerts =>
      state.where((e) => e.status == AlertStatus.active).toList();

  List<AlertModel> get alertHistory =>
      state.where((e) => e.status == AlertStatus.resolved).toList();

  /// Criar alerta
  Future<bool> createAlert({
    required String title,
    required String description,
    required AlertLevel level,
    required bool requiresConfirmation,
    required List<String> sectors,
  }) async {
    try {
      final alert = AlertModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        level: level,
        status: AlertStatus.active,
        createdAt: DateTime.now(),
        sectors: sectors,
        requiresConfirmation: requiresConfirmation,
      );

      state = [...state, alert];
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  /// Resolver alerta
  Future<bool> resolveAlert({
    required String id,
    required String resolutionMessage,
  }) async {
    try {
      final index = state.indexWhere((a) => a.id == id);

      if (index == -1) return false;

      final alert = state[index];

      final updated = AlertModel(
        id: alert.id,
        title: alert.title,
        description: alert.description,
        level: alert.level,
        status: AlertStatus.resolved,
        createdAt: alert.createdAt,
        resolvedAt: DateTime.now(),
        resolutionMessage: resolutionMessage,
        sectors: alert.sectors,
        requiresConfirmation: alert.requiresConfirmation,
        readCount: alert.readCount,
        totalUsers: alert.totalUsers,
        readRate: alert.readRate,
      );

      final newState = [...state];
      newState[index] = updated;

      state = newState;

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    }
  }

  /// Carregar alertas ativos
  Future<void> loadActiveAlerts() async {
    try {
      isLoadingActive = true;

      await Future.delayed(const Duration(milliseconds: 500));

      isLoadingActive = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoadingActive = false;
    }
  }

  /// Carregar histórico
  Future<void> loadHistory() async {
    try {
      isLoadingHistory = true;

      await Future.delayed(const Duration(milliseconds: 500));

      isLoadingHistory = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoadingHistory = false;
    }
  }

  /// Atualizar leitura
  void markAsRead(String id) {
    final index = state.indexWhere((a) => a.id == id);

    if (index == -1) return;

    final alert = state[index];

    final updated = AlertModel(
      id: alert.id,
      title: alert.title,
      description: alert.description,
      level: alert.level,
      status: alert.status,
      createdAt: alert.createdAt,
      resolvedAt: alert.resolvedAt,
      resolutionMessage: alert.resolutionMessage,
      sectors: alert.sectors,
      requiresConfirmation: alert.requiresConfirmation,
      readCount: alert.readCount + 1,
      totalUsers: alert.totalUsers,
      readRate: alert.totalUsers == 0
          ? 0
          : (alert.readCount + 1) / alert.totalUsers,
    );

    final newState = [...state];
    newState[index] = updated;

    state = newState;
  }
}
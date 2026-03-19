import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import '../models/alert_status.dart'; 
import '../models/alert_state.dart'; 

final alertServiceProvider = Provider((ref) => AlertService());

final alertProvider = StateNotifierProvider<AlertNotifier, AlertState>((ref) {
  final service = ref.watch(alertServiceProvider);
  return AlertNotifier(service);
});

class AlertNotifier extends StateNotifier<AlertState> {
  final AlertService _service;

  AlertNotifier(this._service) : super(AlertState()) {
    loadActiveAlerts();
    loadHistory(); // Adicionado para carregar ambos ao iniciar
  }

  Future<void> notifyPendingSectors(List<String> sectors) async {
    try {
      await _service.notifyPendingSectors(sectors);
      await loadActiveAlerts();
    } catch (e) {
      print("Erro ao notificar: $e");
    }
  }

 Future<bool> createAlert({
  required String title,
  required String description,
  required AlertLevel level,
  required bool requiresConfirmation,
  required List<String> sectors,
}) async {
  try {
    // 1. Chama o service
    final newAlert = await _service.createAlert(
      title: title,
      description: description,
      level: level,
      requiresConfirmation: level == AlertLevel.critical ? true : requiresConfirmation,
      sectors: sectors,
    );

    // 2. Atualiza o estado criando uma NOVA instância da lista
    // Isso garante que o ref.watch perceba a mudança de referência
    state = state.copyWith(
      activeAlerts: List.from([newAlert, ...state.activeAlerts]), 
    );

    // Opcional: Recarregar do banco para garantir sincronia total com IDs gerados no backend
    // await loadActiveAlerts(); 

    return true;
  } catch (e) {
    print("Erro ao criar alerta: $e");
    return false;
  }
}

  Future<bool> resolveAlert({
    required String id,
    required String resolutionMessage,
  }) async {
    try {
      final updatedAlert = await _service.resolveAlert(
        id: id,
        resolutionMessage: resolutionMessage,
      );

      final newActive = state.activeAlerts.where((a) => a.id != id).toList();
      final newHistory = [updatedAlert, ...state.history];

      state = state.copyWith(
        activeAlerts: newActive,
        history: newHistory,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadActiveAlerts() async {
    state = state.copyWith(isLoadingActive: true);
    try {
      final alerts = await _service.getActiveAlerts();
      state = state.copyWith(activeAlerts: alerts, isLoadingActive: false);
    } catch (e) {
      state = state.copyWith(isLoadingActive: false);
    }
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoadingHistory: true);
    try {
      final alerts = await _service.getAlertHistory();
      state = state.copyWith(history: alerts, isLoadingHistory: false);
    } catch (e) {
      state = state.copyWith(isLoadingHistory: false);
    }
  }

  void markAsRead(String id) {
    state = state.copyWith(
      // Nota: Certifique-se que seu AlertModel tem o método copyWith e o campo isRead
      history: state.history.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList(),
      activeAlerts: state.activeAlerts.map((a) => a.id == id ? a.copyWith(isRead: true) : a).toList(),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_state.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';

final alertServiceProvider = Provider<AlertService>((ref) => AlertService());

final alertProvider = StateNotifierProvider<AlertNotifier, AlertState>((ref) {
  return AlertNotifier(ref.read(alertServiceProvider));
});

class AlertNotifier extends StateNotifier<AlertState> {
  final AlertService _service;

  AlertNotifier(this._service) : super(const AlertState());

  Future<void> loadNotifications() async {
    if (state.isLoadingNotifications) return;
    state = state.copyWith(isLoadingNotifications: true, clearError: true);
    try {
      final notifications = await _service.getNotifications();
      state = state.copyWith(
        notifications: notifications,
        isLoadingNotifications: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingNotifications: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingNotifications: false,
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  Future<void> loadAssignments() async {
    if (state.isLoadingAssignments) return;
    state = state.copyWith(isLoadingAssignments: true, clearError: true);
    try {
      final assignments = await _service.getMyAssignments();
      state = state.copyWith(
        assignments: assignments,
        isLoadingAssignments: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingAssignments: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingAssignments: false,
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  Future<bool> createNotification({
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    String? sectorId,
  }) async {
    try {
      final created = await _service.createNotification(
        title: title,
        message: message,
        level: level,
        slaMinutes: slaMinutes,
        requiresAcknowledgment: requiresAcknowledgment,
        sectorId: sectorId,
      );
      state = state.copyWith(
        notifications: [created, ...state.notifications],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro inesperado. Tente novamente.');
      return false;
    }
  }

  Future<bool> createGlobalNotification({
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
  }) async {
    try {
      final created = await _service.createNotification(
        title: title,
        message: message,
        level: level,
        slaMinutes: slaMinutes,
        requiresAcknowledgment: requiresAcknowledgment,
        sectorId: null,
      );
      state = state.copyWith(
        notifications: [created, ...state.notifications],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro inesperado. Tente novamente.');
      return false;
    }
  }

  Future<void> markAsViewed(String assignmentId) async {
    try {
      await _service.markAsViewed(assignmentId);
      final now = DateTime.now();
      state = state.copyWith(
        assignments: state.assignments.map((a) {
          if (a.id != assignmentId) return a;
          final autoAck = !(a.requiresAcknowledgment ?? false) && !a.isCritical;
          return autoAck
              ? a.copyWith(
                  status: AssignmentStatus.acknowledged,
                  viewedAt: now,
                  acknowledgedAt: now,
                )
              : a.copyWith(status: AssignmentStatus.viewed, viewedAt: now);
        }).toList(),
      );
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {}
  }

  Future<void> acknowledge(String assignmentId) async {
    try {
      await _service.acknowledge(assignmentId);
    } on ApiException catch (e) {
      // 409 = já confirmado — estado local já é o correto, ignora
      if (e.statusCode == 409) return;
      state = state.copyWith(errorMessage: e.message);
      return;
    } catch (_) {
      return;
    }
    final now = DateTime.now();
    state = state.copyWith(
      assignments: state.assignments
          .map((a) => a.id == assignmentId
              ? a.copyWith(
                  status: AssignmentStatus.acknowledged,
                  acknowledgedAt: now,
                )
              : a)
          .toList(),
    );
  }

  Future<void> loadAllAssignments() async {
    if (state.isLoadingAllAssignments) return;
    state = state.copyWith(isLoadingAllAssignments: true, clearError: true);
    try {
      final all = await _service.getAllAssignments();
      state = state.copyWith(allAssignments: all, isLoadingAllAssignments: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoadingAllAssignments: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingAllAssignments: false,
        errorMessage: 'Erro inesperado. Tente novamente.',
      );
    }
  }

  Future<void> syncDeliveries() async {
    try {
      await _service.syncDeliveries();
    } catch (_) {}
  }

  Future<void> markAllPendingAsViewed() async {
    final pending = state.assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .toList();
    for (final a in pending) {
      await markAsViewed(a.id);
    }
  }
}

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

  String get _token => ApiClient.currentToken;

  Future<void> loadNotifications({String? token}) async {
    state = state.copyWith(isLoadingNotifications: true);
    try {
      final notifications =
          await _service.getNotifications(token: token ?? _token);
      state = state.copyWith(
        notifications: notifications,
        isLoadingNotifications: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingNotifications: false);
    }
  }

  Future<void> loadAssignments({String? token}) async {
    state = state.copyWith(isLoadingAssignments: true);
    try {
      final assignments =
          await _service.getMyAssignments(token: token ?? _token);
      state = state.copyWith(
        assignments: assignments,
        isLoadingAssignments: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingAssignments: false);
    }
  }

  Future<bool> createNotification({
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    String? sectorId,
    String? token,
  }) async {
    try {
      final created = await _service.createNotification(
        token: token ?? _token,
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
    } catch (_) {
      return false;
    }
  }

  Future<void> markAsViewed({required String assignmentId, String? token}) async {
    try {
      final updated = await _service.markAsViewed(
        assignmentId: assignmentId,
        token: token ?? _token,
      );
      _updateAssignment(updated);
    } catch (_) {}
  }

  Future<void> acknowledge({required String assignmentId, String? token}) async {
    try {
      final updated = await _service.acknowledge(
        assignmentId: assignmentId,
        token: token ?? _token,
      );
      _updateAssignment(updated);
    } catch (_) {}
  }

  void _updateAssignment(AssignmentModel updated) {
    state = state.copyWith(
      assignments: state.assignments
          .map((a) => a.id == updated.id ? updated : a)
          .toList(),
    );
  }
}

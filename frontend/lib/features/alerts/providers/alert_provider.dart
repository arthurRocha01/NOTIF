import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart' show ApiClient;
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
    if (state.isLoadingNotifications) return;
    state = state.copyWith(isLoadingNotifications: true, clearError: true);
    try {
      final notifications =
          await _service.getNotifications(token: token ?? _token);
      state = state.copyWith(
        notifications: notifications,
        isLoadingNotifications: false,
      );
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
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

  Future<void> loadAssignments({required String userId, String? token}) async {
    if (state.isLoadingAssignments) return;
    state = state.copyWith(isLoadingAssignments: true, clearError: true);
    try {
      final assignments =
          await _service.getMyAssignments(userId: userId, token: token ?? _token);
      state = state.copyWith(
        assignments: assignments,
        isLoadingAssignments: false,
      );
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
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
    required String authorId,
    String? sectorId,
    String? token,
  }) async {
    try {
      final created = await _service.createNotification(
        token: token ?? _token,
        authorId: authorId,
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
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro inesperado. Tente novamente.');
      return false;
    }
  }

  Future<bool> createNotificationForAllSectors({
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    required String authorId,
    required List<String> sectorIds,
    String? token,
  }) async {
    if (sectorIds.isEmpty) {
      state = state.copyWith(errorMessage: 'Nenhum setor disponível.');
      return false;
    }
    try {
      final created = <AlertModel>[];
      for (final sectorId in sectorIds) {
        final notification = await _service.createNotification(
          token: token ?? _token,
          authorId: authorId,
          title: title,
          message: message,
          level: level,
          slaMinutes: slaMinutes,
          requiresAcknowledgment: requiresAcknowledgment,
          sectorId: sectorId,
        );
        created.add(notification);
      }
      state = state.copyWith(
        notifications: [...created, ...state.notifications],
      );
      return true;
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
      state = state.copyWith(errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro inesperado. Tente novamente.');
      return false;
    }
  }

  Future<void> markAsViewed(
      {required String assignmentId, String? token}) async {
    try {
      await _service.markAsViewed(
        assignmentId: assignmentId,
        token: token ?? _token,
      );
      final now = DateTime.now();
      state = state.copyWith(
        assignments: state.assignments
            .map((a) => a.id == assignmentId
                ? a.copyWith(status: AssignmentStatus.viewed, viewedAt: now)
                : a)
            .toList(),
      );
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {}
  }

  Future<void> acknowledge(
      {required String assignmentId, String? token}) async {
    try {
      await _service.acknowledge(
        assignmentId: assignmentId,
        token: token ?? _token,
      );
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
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {}
  }

  Future<void> syncDeliveries(
      {required String userId, String? token}) async {
    try {
      await _service.syncDeliveries(
        userId: userId,
        token: token ?? _token,
      );
    } on AlertServiceException catch (e) {
      if (e.statusCode == 401) ApiClient.onUnauthorized?.call();
    } catch (_) {}
  }

  Future<void> markAllPendingAsViewed({String? token}) async {
    final pending = state.assignments
        .where((a) => a.status == AssignmentStatus.pending)
        .toList();
    for (final a in pending) {
      await markAsViewed(assignmentId: a.id, token: token);
    }
  }

}

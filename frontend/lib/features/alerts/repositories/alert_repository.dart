import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../services/alert_service.dart';

class AlertRepository {
  final AlertService _service;

  AlertRepository({AlertService? service})
      : _service = service ?? AlertService();

  Future<List<AlertModel>> fetchNotifications({required String token}) =>
      _service.getNotifications(token: token);

  Future<AlertModel> createNotification({
    required String token,
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    String? sectorId,
  }) =>
      _service.createNotification(
        token: token,
        title: title,
        message: message,
        level: level,
        slaMinutes: slaMinutes,
        requiresAcknowledgment: requiresAcknowledgment,
        sectorId: sectorId,
      );

  Future<List<AssignmentModel>> fetchMyAssignments({required String token}) =>
      _service.getMyAssignments(token: token);

  Future<AssignmentModel> markAsViewed({
    required String assignmentId,
    required String token,
  }) =>
      _service.markAsViewed(assignmentId: assignmentId, token: token);

  Future<AssignmentModel> acknowledge({
    required String assignmentId,
    required String token,
  }) =>
      _service.acknowledge(assignmentId: assignmentId, token: token);
}

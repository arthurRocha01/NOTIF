import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/assignment_model.dart';
import 'package:notif_app/features/alerts/models/my_assignment_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';

class AlertService {
  Future<List<AlertModel>> getNotifications({AlertLevel? level, String? sectorId}) async {
    final params = [
      if (level != null) 'level=${level.backendValue}',
      if (sectorId != null) 'sectorId=$sectorId',
    ];
    final query = params.isNotEmpty ? '?${params.join("&")}' : '';
    final data = await ApiClient.get('/notifications$query');
    return (data as List<dynamic>)
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel> createNotification({
    required String title,
    required String message,
    required AlertLevel level,
    required int slaMinutes,
    required bool requiresAcknowledgment,
    String? sectorId,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'message': message,
      'level': level.backendValue,
      'slaMinutes': slaMinutes,
      'requiresAcknowledgment': requiresAcknowledgment,
      if (sectorId != null) 'sectorId': sectorId,
    };
    final data = await ApiClient.post('/notifications', payload);
    return AlertModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MyAssignmentModel>> getBlockingAssignments() async {
    final data = await ApiClient.get('/assignments/blocking');
    return (data as List<dynamic>)
        .map((e) => MyAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MyAssignmentModel>> getMyAssignments({List<AssignmentStatus>? statuses}) async {
    final query = (statuses != null && statuses.isNotEmpty)
        ? '?status=${statuses.map((s) => s.backendValue).join(",")}'
        : '';
    final data = await ApiClient.get('/assignments/mine$query');
    return (data as List<dynamic>)
        .map((e) => MyAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AssignmentModel>> getAllAssignments() async {
    final data = await ApiClient.get('/assignments');
    return (data as List<dynamic>)
        .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsViewed(String assignmentId) async {
    await ApiClient.post('/assignments/$assignmentId/view', {});
  }

  Future<void> acknowledge(String assignmentId) async {
    await ApiClient.post('/assignments/$assignmentId/acknowledge', {});
  }

  Future<void> syncDeliveries() async {
    await ApiClient.post('/assignments/sync', {});
  }
}

import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';

class AlertService {
  Future<List<AlertModel>> getNotifications() async {
    final data = await ApiClient.get('/notifications');
    return (data as List<dynamic>)
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel> createNotification({
    required String authorId,
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
      'requiresAcknowledgment': level == AlertLevel.critical ? true : requiresAcknowledgment,
      'authorId': authorId,
      if (sectorId != null) 'sectorId': sectorId,
    };
    final data = await ApiClient.post('/notifications', payload);
    return AlertModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AssignmentModel>> getMyAssignments() async {
    final data = await ApiClient.get('/assignments/mine');
    return (data as List<dynamic>)
        .map((e) => AssignmentModel.fromJson(e as Map<String, dynamic>))
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

  Future<void> syncDeliveries(String userId) async {
    await ApiClient.post('/assignments/sync/$userId', {});
  }
}

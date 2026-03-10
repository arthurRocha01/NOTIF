import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../../../core/api/api_client.dart';

class AlertService {
  Future<List<AlertModel>> getAlerts() async {
    final response = await ApiClient.get('/alerts');
    final list = response as List<dynamic>;
    return list
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AlertModel>> getActiveAlerts() async {
    final response = await ApiClient.get('/alerts/active');
    final list = response as List<dynamic>;
    return list
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AlertModel>> getAlertHistory() async {
    final response = await ApiClient.get('/alerts/history');
    final list = response as List<dynamic>;
    return list
        .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel> getAlertById(String id) async {
    final response = await ApiClient.get('/alerts/$id');
    return AlertModel.fromJson(response as Map<String, dynamic>);
  }

  Future<AlertModel> createAlert({
    required String title,
    required String description,
    required AlertLevel level,
    required bool requiresConfirmation,
    required List<String> sectors,
  }) async {
    final response = await ApiClient.post('/alerts', {
      'title': title,
      'description': description,
      'level': level.name,
      'requiresConfirmation': requiresConfirmation,
      'sectors': sectors,
    });
    return AlertModel.fromJson(response as Map<String, dynamic>);
  }

  Future<AlertModel> resolveAlert({
    required String id,
    required String resolutionMessage,
  }) async {
    final response = await ApiClient.patch('/alerts/$id/resolve', {
      'resolutionMessage': resolutionMessage,
    });
    return AlertModel.fromJson(response as Map<String, dynamic>);
  }

  Future<void> markAsRead(String id) async {
    await ApiClient.post('/alerts/$id/read', {});
  }
}
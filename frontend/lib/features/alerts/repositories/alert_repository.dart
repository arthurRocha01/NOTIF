import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../services/alert_service.dart';

class AlertRepository {
  final AlertService _service;

  AlertRepository({AlertService? service})
      : _service = service ?? AlertService();

  Future<List<AlertModel>> fetchAllAlerts() => _service.getAlerts();

  Future<List<AlertModel>> fetchActiveAlerts() => _service.getActiveAlerts();

  Future<List<AlertModel>> fetchAlertHistory() => _service.getAlertHistory();

  Future<AlertModel> fetchAlertById(String id) =>
      _service.getAlertById(id);

  Future<AlertModel> createAlert({
    required String title,
    required String description,
    required AlertLevel level,
    required bool requiresConfirmation,
    required List<String> sectors,
  }) =>
      _service.createAlert(
        title: title,
        description: description,
        level: level,
        requiresConfirmation: requiresConfirmation,
        sectors: sectors,
      );

  Future<AlertModel> resolveAlert({
    required String id,
    required String resolutionMessage,
  }) =>
      _service.resolveAlert(id: id, resolutionMessage: resolutionMessage);

  Future<void> markAsRead(String id) => _service.markAsRead(id);
}
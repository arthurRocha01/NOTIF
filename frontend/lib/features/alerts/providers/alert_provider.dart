import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../models/alert_status.dart';
import '../repositories/alert_repository.dart';

enum AlertLoadState { initial, loading, loaded, error }

class AlertProvider extends ChangeNotifier {
  final AlertRepository _repository;

  AlertLoadState _activeState = AlertLoadState.initial;
  AlertLoadState _historyState = AlertLoadState.initial;

  List<AlertModel> _activeAlerts = [];
  List<AlertModel> _alertHistory = [];
  AlertModel? _selectedAlert;
  String? _errorMessage;

  AlertProvider({AlertRepository? repository})
      : _repository = repository ?? AlertRepository();

  AlertLoadState get activeState => _activeState;
  AlertLoadState get historyState => _historyState;
  List<AlertModel> get activeAlerts => _activeAlerts;
  List<AlertModel> get alertHistory => _alertHistory;
  AlertModel? get selectedAlert => _selectedAlert;
  String? get errorMessage => _errorMessage;

  bool get isLoadingActive => _activeState == AlertLoadState.loading;
  bool get isLoadingHistory => _historyState == AlertLoadState.loading;

  Future<void> loadActiveAlerts() async {
    _activeState = AlertLoadState.loading;
    notifyListeners();
    try {
      _activeAlerts = await _repository.fetchActiveAlerts();
      _activeState = AlertLoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _activeState = AlertLoadState.error;
    }
    notifyListeners();
  }

  Future<void> loadAlertHistory() async {
    _historyState = AlertLoadState.loading;
    notifyListeners();
    try {
      _alertHistory = await _repository.fetchAlertHistory();
      _historyState = AlertLoadState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _historyState = AlertLoadState.error;
    }
    notifyListeners();
  }

  Future<void> selectAlert(String id) async {
    try {
      _selectedAlert = await _repository.fetchAlertById(id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
      final alert = await _repository.createAlert(
        title: title,
        description: description,
        level: level,
        requiresConfirmation: requiresConfirmation,
        sectors: sectors,
      );
      _activeAlerts = [alert, ..._activeAlerts];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> resolveAlert({
    required String id,
    required String resolutionMessage,
  }) async {
    try {
      final resolved = await _repository.resolveAlert(
        id: id,
        resolutionMessage: resolutionMessage,
      );
      _activeAlerts = _activeAlerts.where((a) => a.id != id).toList();
      _alertHistory = [resolved, ..._alertHistory];
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      _activeAlerts = _activeAlerts.map((a) {
        if (a.id == id) {
          return a.copyWith(
            readCount: a.readCount + 1,
            readRate: a.totalUsers > 0
                ? (a.readCount + 1) / a.totalUsers
                : 0,
          );
        }
        return a;
      }).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
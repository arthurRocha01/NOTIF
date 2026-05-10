import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/services/alert_service.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/login/services/fcm_service.dart';
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final fcmServiceProvider = Provider<FcmService>((ref) => FcmService());
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
    ref.read(alertServiceProvider),
    ref.read(fcmServiceProvider),
  );
});

final authInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).tryRestoreSession();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _service;
  final TokenStorage _storage;
  final AlertService _alertService;
  final FcmService _fcmService;
  String? _errorMessage;
  StreamSubscription<String>? _tokenRefreshSub;

  AuthNotifier(
    this._service,
    this._storage,
    this._alertService,
    this._fcmService,
  ) : super(null) {
    ApiClient.onUnauthorized = () => logout();
  }

  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final token = await _service.login(email, password);
      ApiClient.setToken(token);
      final user = await _service.fetchProfile();
      await _storage.saveToken(token);
      state = user;
      _syncDeliveriesSilently(state!.id);
      _startTokenRefreshListener();
      _fcmService.requestPermission().then((_) => _syncFcmTokenSilently(state!)).catchError((_) {});
      return true;

    } on ApiException catch (e) {
      ApiClient.clearToken();
      _errorMessage = e.message;
      state = null;
      return false;
    } catch (_) {
      ApiClient.clearToken();
      _errorMessage = 'Erro inesperado. Tente novamente.';
      state = null;
      return false;
    }
  }

  Future<void> tryRestoreSession() async {
    final token = await _storage.getToken();
    if (token == null) return;
    try {
      ApiClient.setToken(token);
      state = await _service.fetchProfile();
      _syncDeliveriesSilently(state!.id);
      _startTokenRefreshListener();
      _fcmService.requestPermission().then((_) => _syncFcmTokenSilently(state!)).catchError((_) {});
    } on ApiException catch (e) {
      ApiClient.clearToken();
      if (e.statusCode == 401) {
        await _storage.clearAll();
      }
    } catch (_) {
      ApiClient.clearToken();
    }
  }

  Future<void> updateName(String name) async {
    await ApiClient.patch('/users/${state!.id}', {'name': name});
    state = state!.copyWith(name: name);
  }

  void logout() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    ApiClient.clearToken();
    _storage.clearAll();
    _errorMessage = null;
    state = null;
  }

  @override
  void dispose() {
    _tokenRefreshSub?.cancel();
    super.dispose();
  }

  void _startTokenRefreshListener() {
    try {
      _tokenRefreshSub?.cancel();
      _tokenRefreshSub = _fcmService.onTokenRefresh.listen((newToken) async {
        final current = state;
        if (current == null) return;
        try {
          await _service.updateFcmToken(newToken);
          if (state != null) {
            state = state!.copyWith(fcmToken: newToken);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  void _syncDeliveriesSilently(String userId) {
    _alertService.syncDeliveries().catchError((_) {});
  }

  void _syncFcmTokenSilently(UserModel user) {
    _syncFcmToken(user).catchError((_) {});
  }

  Future<void> _syncFcmToken(UserModel user) async {
    final deviceToken = await _fcmService.getToken();
    if (deviceToken == null || deviceToken == user.fcmToken) return;
    await _service.updateFcmToken(deviceToken);
    if (state != null) {
      state = state!.copyWith(fcmToken: deviceToken);
    }
  }
}

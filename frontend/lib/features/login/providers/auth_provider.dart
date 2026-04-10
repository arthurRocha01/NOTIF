import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
  );
});

final authInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).tryRestoreSession();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _service;
  final TokenStorage _storage;
  String? _errorMessage;

  AuthNotifier(this._service, this._storage) : super(null);

  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final token = await _service.login(email, password);
      ApiClient.setToken(token);
      await _storage.saveToken(token);
      await _storage.saveEmail(email);
      final user = await _service.fetchUser(email, token);
      state = user;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      state = null;
      return false;
    } catch (_) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      state = null;
      return false;
    }
  }

  Future<void> tryRestoreSession() async {
    final token = await _storage.getToken();
    final email = await _storage.getEmail();
    if (token == null || email == null) return;
    try {
      ApiClient.setToken(token);
      final user = await _service.fetchUser(email, token);
      state = user;
    } catch (_) {
      ApiClient.clearToken();
      await _storage.clearAll();
    }
  }

  void logout() {
    ApiClient.clearToken();
    _storage.clearAll();
    _errorMessage = null;
    state = null;
  }
}

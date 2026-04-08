import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/login/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _service;
  String? _errorMessage;

  AuthNotifier(this._service) : super(null);

  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final token = await _service.login(email, password);
      ApiClient.setToken(token);
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

  void logout() {
    ApiClient.clearToken();
    _errorMessage = null;
    state = null;
  }
}

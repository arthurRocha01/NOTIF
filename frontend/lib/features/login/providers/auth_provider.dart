import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/storage/token_storage.dart';
import 'package:notif_app/features/login/services/auth_service.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/sectors/services/sector_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier(
    ref.read(authServiceProvider),
    ref.read(tokenStorageProvider),
    ref.read(sectorServiceProvider),
  );
});

final authInitProvider = FutureProvider<void>((ref) async {
  await ref.read(authProvider.notifier).tryRestoreSession();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  final AuthService _service;
  final TokenStorage _storage;
  final SectorService _sectorService;
  String? _errorMessage;

  AuthNotifier(this._service, this._storage, this._sectorService) : super(null);

  String? get errorMessage => _errorMessage;

  /// Tenta resolver o sectorId do usuário para o nome legível do setor.
  /// Usa o token já setado em [ApiClient.currentToken].
  /// Em caso de falha ou setor não encontrado, retorna o usuário com o valor original.
  Future<UserModel> _resolveUser(UserModel user) async {
    try {
      final sectors =
          await _sectorService.getSectors(token: ApiClient.currentToken);
      final match = sectors.firstWhere(
        (s) => s.id == user.sector,
        orElse: () => throw StateError('not found'),
      );
      return UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        sector: match.name,
        role: user.role,
        avatar: user.avatar,
      );
    } catch (_) {
      return user;
    }
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    try {
      final token = await _service.login(email, password);
      ApiClient.setToken(token);
      await _storage.saveToken(token);
      await _storage.saveEmail(email);
      final raw = await _service.fetchUser(email, token);
      state = await _resolveUser(raw);
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
      final raw = await _service.fetchUser(email, token);
      state = await _resolveUser(raw);
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

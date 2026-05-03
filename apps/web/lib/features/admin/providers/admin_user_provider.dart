import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/services/admin_sector_service.dart';
import 'package:notif_app/features/admin/services/admin_user_service.dart';

class AdminUserState {
  final List<UserModel> users;
  final bool isLoading;
  final String? errorMessage;

  const AdminUserState({
    this.users = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminUserState copyWith({
    List<UserModel>? users,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminUserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final adminUserServiceProvider =
    Provider<AdminUserService>((ref) => AdminUserService());

final adminUserProvider =
    StateNotifierProvider<AdminUserNotifier, AdminUserState>((ref) {
  return AdminUserNotifier(
    ref.read(adminUserServiceProvider),
    ref.read(adminSectorServiceProvider),
  );
});

class AdminUserNotifier extends StateNotifier<AdminUserState> {
  final AdminUserService _service;
  final AdminSectorService _sectorService;

  AdminUserNotifier(this._service, this._sectorService)
      : super(const AdminUserState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final usersFuture = _service.getUsers();
      final sectorsFuture = _sectorService.getSectors();
      final users = await usersFuture;
      final sectors = await sectorsFuture;
      final sectorMap = {for (final s in sectors) s.id: s.name};
      final enriched = users
          .map((u) => u.copyWith(sectorName: sectorMap[u.sectorId] ?? ''))
          .toList();
      state = state.copyWith(users: enriched, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Erro ao carregar usuários');
    }
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String sectorId,
  }) async {
    try {
      final user = await _service.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
        sectorId: sectorId,
      );
      state = state.copyWith(users: [...state.users, user], clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro ao criar usuário');
    }
  }

  Future<void> updateUser({
    required String userId,
    String? name,
    String? role,
    String? sectorId,
  }) async {
    try {
      final updated = await _service.updateUser(
        userId: userId,
        name: name,
        role: role,
        sectorId: sectorId,
      );
      state = state.copyWith(
        users: state.users.map((u) => u.id == userId ? updated : u).toList(),
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro ao atualizar usuário');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _service.deleteUser(userId);
      state = state.copyWith(
        users: state.users.where((u) => u.id != userId).toList(),
        clearError: true,
      );
    } on ApiException catch (e) {
      state = state.copyWith(errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(errorMessage: 'Erro ao deletar usuário');
    }
  }
}

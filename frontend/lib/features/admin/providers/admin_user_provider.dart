import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
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
  return AdminUserNotifier(ref.read(adminUserServiceProvider));
});

class AdminUserNotifier extends StateNotifier<AdminUserState> {
  final AdminUserService _service;

  AdminUserNotifier(this._service) : super(const AdminUserState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final users = await _service.getUsers();
      state = state.copyWith(users: users, isLoading: false);
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

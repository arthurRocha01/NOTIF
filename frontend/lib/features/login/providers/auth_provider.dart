import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/model/user_model.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  Future<bool> login(String email, String password) async {
    // Simula um atraso de rede
    await Future.delayed(const Duration(milliseconds: 800));

    // 1. Validação para a Roberta (ADMIN)
    if (email == 'admin123@gmail.com' && password == 'admin123') {
      state = const UserModel(
        id: 'admin-01',
        name: 'Roberta Martins',
        email: 'admin123@gmail.com',
        sector: 'Operações',
        role: UserRole.supervisor, // Roberta cai no AlertsAdminScreen
      );
      return true;
    } 
    
    // 2. Validação para o João (USER)
    if (email == 'user123@gmail.com' && password == 'user123') {
      state = const UserModel(
        id: 'user-02',
        name: 'João Silva',
        email: 'user123@gmail.com',
        sector: 'Logística',
        role: UserRole.employee, // João cai no AlertsUserScreen
      );
      return true;
    }

    // Se não cair em nenhum dos IFs acima, login falhou
    state = null;
    return false;
  }

  void logout() => state = null;
}
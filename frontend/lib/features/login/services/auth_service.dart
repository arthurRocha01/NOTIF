

import 'package:notif_app/core/model/user_model.dart';

class AuthService {
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.contains("admin")) {
      return UserModel(
        id: "100",
        name: "Roberta Oliveira",
        email: email,
        sector: "Operações", // Setor da Roberta
        role: UserRole.supervisor,
      );
    }
    
    return UserModel(
      id: "200",
      name: "João Silva",
      email: email,
      sector: "Logística", // Setor do João
      role: UserRole.employee,
    );
  }
}
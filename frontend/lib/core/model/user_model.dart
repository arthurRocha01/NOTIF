import 'package:file_picker/file_picker.dart';

enum UserRole { supervisor, employee, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String sector;
  final UserRole role;
  final PlatformFile? avatar;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.sector,
    required this.role,
    this.avatar,
    this.fcmToken,
  });

  bool get isSupervisor => role == UserRole.supervisor;
  bool get isAdmin => role == UserRole.admin;
  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return "Administrador";
      case UserRole.supervisor:
        return "Supervisor";
      case UserRole.employee:
        return "Colaborador";
    }
  }
}
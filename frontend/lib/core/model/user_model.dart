import 'package:file_picker/file_picker.dart';

enum UserRole { supervisor, employee }

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

  // Garante que a UI saiba quem é admin
  bool get isSupervisor => role == UserRole.supervisor;
  String get roleLabel => isSupervisor ? "Supervisor" : "Funcionário";
}
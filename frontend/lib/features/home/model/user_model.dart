import 'package:file_picker/file_picker.dart';

class UserModel {
  final String id;
  final String name;
  final String role;
  final PlatformFile? avatar;

  const UserModel({
    required this.id,
    required this.name,
    required this.role,
    this.avatar,
  });
}
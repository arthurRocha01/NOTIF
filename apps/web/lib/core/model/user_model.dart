enum UserRole { supervisor, employee, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String sectorId;
  final String sectorName;
  final UserRole role;
  final String? fcmToken;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.sectorId,
    this.sectorName = '',
    required this.role,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> data) => UserModel(
        id: data['id'] as String,
        name: data['name'] as String,
        email: data['email'] as String,
        sectorId: data['sectorId'] as String? ?? '',
        sectorName: data['sectorName'] as String? ?? '',
        role: data['role'] == 'ADMIN'
            ? UserRole.admin
            : data['role'] == 'SUPERVISOR'
                ? UserRole.supervisor
                : UserRole.employee,
        fcmToken: data['fcmToken'] as String?,
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? sectorId,
    String? sectorName,
    UserRole? role,
    String? fcmToken,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      sectorId: sectorId ?? this.sectorId,
      sectorName: sectorName ?? this.sectorName,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  bool get isSupervisor => role == UserRole.supervisor;
  bool get isAdmin => role == UserRole.admin;

  String get roleLabel {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.employee:
        return 'Colaborador';
    }
  }
}

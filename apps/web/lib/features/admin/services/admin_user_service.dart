import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';

class AdminUserService {
  Future<List<UserModel>> getUsers() async {
    final data = await ApiClient.get('/users');
    return (data as List<dynamic>)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String sectorId,
  }) async {
    final data = await ApiClient.post('/users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'sectorId': sectorId,
      'fcmToken': '',
    });
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> updateUser({
    required String userId,
    String? name,
    String? role,
    String? sectorId,
  }) async {
    final body = <String, dynamic>{
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (sectorId != null) 'sectorId': sectorId,
    };
    final data = await ApiClient.patch('/users/$userId', body);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteUser(String userId) async {
    await ApiClient.delete('/users/$userId');
  }
}

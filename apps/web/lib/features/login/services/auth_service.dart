import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';

class AuthService {
  Future<String> login(String email, String password) async {
    final data = await ApiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    return data['access_token'] as String;
  }

  Future<UserModel> fetchUser(String email) async {
    final data = await ApiClient.get('/users/by-email/$email');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateFcmToken({
    required String userId,
    required String fcmToken,
  }) async {
    await ApiClient.patch('/users/$userId', {'fcmToken': fcmToken});
  }

  Future<void> updatePassword({
    required String userId,
    required String newPassword,
  }) async {
    await ApiClient.patch('/users/$userId', {'password': newPassword});
  }
}

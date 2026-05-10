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

  Future<UserModel> fetchProfile() async {
    final data = await ApiClient.get('/users/profile');
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await ApiClient.patch('/users/fcm-token', {'fcmToken': fcmToken});
  }

  Future<void> updatePassword(String newPassword) async {
    await ApiClient.patch('/users/password', {'password': newPassword});
  }
}

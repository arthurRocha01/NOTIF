import 'package:shared_preferences/shared_preferences.dart';

class ProfileRepository {
  static const String _photoKey = 'user_profile_photo';

  // Busca do "banco" (SharedPreferences para persistência local)
  Future<String?> getPhotoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_photoKey);
  }

  // Salva no "banco"
  Future<void> savePhotoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_photoKey, path);
    
    // Se fosse uma API, você faria o upload aqui:
    // await dio.post('/upload', data: FormData.fromMap({'file': ...}));
  }
}
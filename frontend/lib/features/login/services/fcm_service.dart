import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Stream<String> get onTokenRefresh => FirebaseMessaging.instance.onTokenRefresh;
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FcmService {
  static bool get _supported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<void> requestPermission() async {
    if (!_supported) return;
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() async {
    if (!_supported) return null;
    return await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb
          ? 'BPbXsA5gRVU3BIt8HoNX0kMZLwohAbna0n5wjg59HgtmaUz1y6rrSafhHh3hGpEiZU6yJHpUFP0miPHM3hVwZRY'
          : null,
    );
  }

  Stream<String> get onTokenRefresh =>
      _supported ? FirebaseMessaging.instance.onTokenRefresh : const Stream.empty();
}

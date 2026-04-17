import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {}

class NotificationService {
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static const _channelId = 'notif_alerts_critical';
  static const _channelName = 'Alertas NOTIF';

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void Function(RemoteMessage)? onForegroundMessage;
  void Function(RemoteMessage)? onNotificationTap;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    if (!_supported) return;

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Taps em notificações locais não requerem ação adicional;
        // FCM onMessageOpenedApp cobre o cenário de tap em push.
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notice_notif'),
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap?.call(message);
    });
  }

  Future<RemoteMessage?> getInitialMessage() =>
      FirebaseMessaging.instance.getInitialMessage();
}

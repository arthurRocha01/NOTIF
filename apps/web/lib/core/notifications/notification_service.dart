import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notif_app/core/notifications/notification_channel.dart';
import 'browser_notification_stub.dart'
    if (dart.library.html) 'browser_notification_web.dart';

@pragma('vm:entry-point')
Future<void> _backgroundMessageHandler(RemoteMessage message) async {
  // Notification messages are displayed by the system automatically.
  // Only handle data-only messages (no notification field).
  if (message.notification != null) return;

  final level = message.data['level'] as String?;
  final channelId = channelForLevel(level);
  final isCritical = isCriticalLevel(level);

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await localNotifications.show(
    message.hashCode,
    message.data['title'] as String? ?? 'Nova notificação',
    message.data['message'] as String?,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        isCritical ? 'Alertas Críticos NOTIF' : 'Alertas NOTIF',
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('notice_notif'),
        enableVibration: true,
        fullScreenIntent: isCritical,
      ),
    ),
  );
}

class NotificationService {
  static final _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  static bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final _localNotifications = FlutterLocalNotificationsPlugin();

  void Function(RemoteMessage)? onForegroundMessage;
  void Function(RemoteMessage)? onNotificationTap;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    if (kIsWeb) {
      FirebaseMessaging.onMessage.listen((message) {
        final n = message.notification;
        if (n != null) {
          showBrowserNotification(n.title ?? 'Nova notificação', n.body);
        }
        onForegroundMessage?.call(message);
      });
      return;
    }

    if (!_supported) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    final plugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // bypassDnd requer NotificationChannel.setBypassDnd() nativo (API 29+),
    // não exposto pelo flutter_local_notifications 18. Configurar via plugin nativo se necessário.
    await plugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'critical',
        'Alertas Críticos NOTIF',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('notice_notif'),
        enableVibration: true,
        playSound: true,
      ),
    );

    await plugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'default',
        'Alertas NOTIF',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notice_notif'),
        enableVibration: true,
        playSound: true,
      ),
    );

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((message) {
      onForegroundMessage?.call(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      onNotificationTap?.call(message);
    });
  }

  Future<void> showLocalNotification({
    required String title,
    String? body,
    int id = 0,
    String? level,
  }) async {
    if (!_supported) return;

    final channelId = channelForLevel(level);
    final isCritical = isCriticalLevel(level);

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          isCritical ? 'Alertas Críticos NOTIF' : 'Alertas NOTIF',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('notice_notif'),
          enableVibration: true,
          fullScreenIntent: isCritical,
        ),
      ),
    );
  }

  Future<RemoteMessage?> getInitialMessage() =>
      FirebaseMessaging.instance.getInitialMessage();
}

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/notifications/notification_service.dart';
import 'package:notif_app/features/alerts/models/alert_model.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/widgets/critical_alert_overlay.dart';
import 'package:notif_app/features/alerts/widgets/in_app_banner_overlay.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/home/widgets/home_bottom_nav.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:notif_app/features/notifications/screens/notifications_screen.dart';
import 'package:notif_app/shared/widgets/home_app_bar.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  OverlayEntry? _bannerEntry;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initNotificationHandlers();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final alert = ref.read(alertProvider.notifier);
      final sector = ref.read(sectorProvider.notifier);
      final user = ref.read(authProvider);
      if (user?.isSupervisor == true || user?.isAdmin == true) {
        await alert.loadNotifications();
      }
      await alert.loadAssignments();
      await sector.loadSectors();
      if (user?.isSupervisor == true) {
        alert.markAllPendingAsViewed();
      }
    });
  }

  void _initNotificationHandlers() {
    final svc = NotificationService();
    svc.onForegroundMessage = _handleForegroundMessage;
    svc.onNotificationTap = _handleNotificationTap;

    svc.getInitialMessage().then((message) {
      if (message != null && mounted) _handleNotificationTap(message);
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (!mounted) return;
    ref.read(alertProvider.notifier).loadAssignments();
    final level = AlertLevel.fromBackend(message.data['level']);
    if (level == AlertLevel.critical) {
      _showCriticalOverlay(message);
    } else {
      _showBanner(message);
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (!mounted) return;
    ref.read(alertProvider.notifier).loadAssignments();
    final level = AlertLevel.fromBackend(message.data['level']);
    if (level == AlertLevel.critical) {
      _showCriticalOverlay(message);
    } else {
      setState(() => _pageIndex = 0);
      ref.read(alertProvider.notifier).markAllPendingAsViewed();
    }
  }

  void _showCriticalOverlay(RemoteMessage message) {
    _playAlertSound();

    final assignment = AssignmentModel(
      id: message.data['assignmentId'] ?? '',
      userId: '',
      notificationId: message.data['notificationId'] ?? '',
      notificationTitle: message.notification?.title ?? message.data['title'],
      notificationMessage:
          message.notification?.body ?? message.data['message'],
      notificationLevel: AlertLevel.fromBackend(message.data['level']),
      status: AssignmentStatus.pending,
      createdAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CriticalAlertOverlay(assignment: assignment),
      ),
    );
  }

  void _showBanner(RemoteMessage message) {
    _bannerEntry?.remove();

    _bannerEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: InAppBannerOverlay(
            title: message.notification?.title ??
                message.data['title'] ??
                'Nova notificação',
            message: message.notification?.body ?? message.data['message'],
            onTap: () {
              _bannerEntry?.remove();
              _bannerEntry = null;
              setState(() => _pageIndex = 0);
            },
            onDismiss: () {
              _bannerEntry?.remove();
              _bannerEntry = null;
            },
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_bannerEntry!);
  }

  void _playAlertSound() {
    try {
      AudioPlayer()
          .play(AssetSource('sounds/notice.notif.wav'))
          .catchError((_) {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isSupervisor = user?.isSupervisor ?? false;

    final pendingCount = ref
        .watch(alertProvider)
        .assignments
        .where((a) => a.status != AssignmentStatus.acknowledged)
        .length;

    // Employee: tela única de notificações, sem navbar
    if (!isSupervisor) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF0D1421),
        appBar: HomeAppBar(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: const AppDrawer(),
        body: const NotificationsScreen(),
      );
    }

    // Supervisor: 3 abas com navbar
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0D1421),
      appBar: HomeAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _pageIndex,
        children: const [
          NotificationsScreen(), // 0 = Notificações
          DashboardScreen(),     // 1 = Dashboard
          AlertAdminScreen(),    // 2 = Painel
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        pageIndex: _pageIndex,
        isSupervisor: true,
        notificationCount: pendingCount,
        onItemTapped: (i) => setState(() => _pageIndex = i),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:html' as html show window, AudioElement;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/notifications/notification_service.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/screen/alerts_user_screen.dart';
import 'package:notif_app/features/alerts/screen/critical_block_screen.dart';
import 'package:notif_app/features/alerts/widgets/in_app_banner_overlay.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';
import 'package:notif_app/features/home/widgets/home_bottom_nav.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
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
  Timer? _pollingTimer;
  final _audioPlayer = AudioPlayer();
  final html.AudioElement? _webAudio = kIsWeb
      ? (html.AudioElement('assets/assets/sounds/notifSound.mp3')..load())
      : null;

  int _pageIndex = 0;
  bool _isCriticalLoopActive = false;
  bool _criticalScreenPushed = false;

  @override
  void initState() {
    super.initState();
    _initNotificationHandlers();
    if (kIsWeb) {
      html.window.addEventListener('pointerdown', _unlockWebAudio);
    }
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
      _checkAndShowBlockScreen();
      _startPolling();
    });
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (ref.read(alertProvider).isBlocked) return;
      final notifier = ref.read(alertProvider.notifier);
      notifier.syncDeliveries();
      notifier.loadAssignments();
    });
  }

  void _unlockWebAudio(dynamic _) {
    html.window.removeEventListener('pointerdown', _unlockWebAudio);
    final audio = _webAudio;
    if (audio == null) return;
    audio.volume = 0;
    audio.play().catchError((_) {});
    audio.onEnded.first.then((_) {
      audio.volume = 1;
      audio.currentTime = 0;
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    if (kIsWeb) html.window.removeEventListener('pointerdown', _unlockWebAudio);
    _audioPlayer.dispose();
    super.dispose();
  }

  void _checkAndShowBlockScreen() {
    if (!mounted || _criticalScreenPushed) return;
    if (ref.read(alertProvider).isBlocked) {
      _criticalScreenPushed = true;
      _startCriticalLoop();
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const CriticalBlockScreen(),
        ),
      ).then((_) => _criticalScreenPushed = false);
    }
  }

  void _startCriticalLoop() {
    if (_isCriticalLoopActive) return;
    _isCriticalLoopActive = true;
    if (kIsWeb) {
      final audio = _webAudio;
      if (audio == null) return;
      audio.loop = true;
      audio.currentTime = 0;
      audio.volume = 1;
      audio.play().catchError((_) {});
    } else {
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
      _audioPlayer.setVolume(1).then((_) =>
          _audioPlayer.play(AssetSource('sounds/notifSound.mp3')).catchError((_) {}));
    }
  }

  void _stopCriticalLoop() {
    _isCriticalLoopActive = false;
    if (kIsWeb) {
      final audio = _webAudio;
      if (audio == null) return;
      audio.loop = false;
      audio.pause();
      audio.currentTime = 0;
    } else {
      _audioPlayer.stop();
      _audioPlayer.setReleaseMode(ReleaseMode.release);
    }
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
    if (level != AlertLevel.critical) {
      _playAlertSound();
      _showBanner(message);
      NotificationService().showLocalNotification(
        title: message.notification?.title ?? message.data['title'] ?? 'Nova notificação',
        body: message.notification?.body ?? message.data['message'],
        id: message.hashCode,
        level: message.data['level'] as String?,
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (!mounted) return;
    ref.read(alertProvider.notifier).loadAssignments();
    setState(() => _pageIndex = 0);
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
    if (kIsWeb) {
      final audio = _webAudio;
      if (audio != null) {
        audio.loop = false;
        audio.currentTime = 0;
        audio.volume = 1;
        audio.play().catchError((_) {});
      }
      return;
    }
    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.setVolume(1).then((_) =>
        _audioPlayer.play(AssetSource('sounds/notifSound.mp3')).catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final bool isSupervisor = user?.isSupervisor ?? false;

    ref.listen<bool>(
      alertProvider.select((s) => s.isBlocked),
      (wasBlocked, isBlocked) {
        if (isBlocked && !(wasBlocked ?? false)) {
          _checkAndShowBlockScreen();
        } else if (!isBlocked && (wasBlocked ?? false)) {
          _stopCriticalLoop();
        }
      },
    );

    final pendingCount = ref
        .watch(alertProvider)
        .assignments
        .where((a) => a.status != AssignmentStatus.acknowledged)
        .length;

    // Employee: tela única de alertas, sem navbar
    if (!isSupervisor) {
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFF0D1421),
        appBar: HomeAppBar(
          onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        drawer: const AppDrawer(),
        body: const AlertUserScreen(),
      );
    }

    // Supervisor: 3 abas — Alertas / Dashboard / Painel
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
          AlertUserScreen(),   // 0 = Alertas
          DashboardScreen(),   // 1 = Dashboard
          AlertAdminScreen(),  // 2 = Painel
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

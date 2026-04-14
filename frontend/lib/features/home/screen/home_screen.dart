import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/models/alert_status.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/screen/alerts_user_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'package:notif_app/features/home/widgets/feed/feed_content.dart';
import 'package:notif_app/features/home/widgets/home_bottom_nav.dart';
import 'package:notif_app/features/home/widgets/publish_modal.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:notif_app/shared/widgets/home_app_bar.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';

final feedProvider = ChangeNotifierProvider((ref) => FeedController());

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(feedProvider).loadPosts());
  }

  // Mapeia o tap na nav bar → pageIndex (0=Feed, 1=Dashboard, 2=Alerts)
  void _onNavTap(int navIndex, bool isSupervisor, FeedController controller, user) {
    if (isSupervisor) {
      // Supervisor: [Home=0, Publicar=1, Dashboard=2, Alertas=3]
      switch (navIndex) {
        case 0: controller.changePage(0); break;
        case 1: _handlePublish(user, controller); break;
        case 2: controller.changePage(1); break;
        case 3: controller.changePage(2); break;
      }
    } else {
      // Employee: [Home=0, Publicar=1, Alertas=2]
      switch (navIndex) {
        case 0: controller.changePage(0); break;
        case 1: _handlePublish(user, controller); break;
        case 2: controller.changePage(2); break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final feedController = ref.watch(feedProvider);
    final bool isSupervisor = user?.isSupervisor ?? false;

    // Contagem real de assignments não confirmados — alimenta o badge da navbar
    final pendingCount = ref
        .watch(alertProvider)
        .assignments
        .where((a) => a.status != AssignmentStatus.acknowledged)
        .length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: HomeAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: feedController.pageIndex,
          children: [
            FeedContent(controller: feedController),        // 0 = Feed
            const DashboardScreen(),                        // 1 = Dashboard
            isSupervisor ? const AlertAdminScreen() : const AlertUserScreen(), // 2 = Alertas
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        pageIndex: feedController.pageIndex,
        isSupervisor: isSupervisor,
        notificationCount: pendingCount,
        onItemTapped: (navIndex) => _onNavTap(navIndex, isSupervisor, feedController, user),
      ),
    );
  }

  void _handlePublish(dynamic user, FeedController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublishModal(
        onPublish: (content, files) async {
          final nav = Navigator.of(context);
          await controller.publish(
            content: content,
            attachments: files,
            currentUser: user,
          );
          nav.pop();
        },
      ),
    );
  }
}

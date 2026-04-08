import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/alerts/screen/alerts_user_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/home/controllers/feed_controller.dart';
import 'package:notif_app/features/home/widgets/feed/feed_content.dart';
import 'package:notif_app/features/home/widgets/home_bottom_nav.dart';
import 'package:notif_app/features/home/widgets/publish_modal.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:notif_app/features/profile/widgets/home_app_bar.dart';
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
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final feedController = ref.watch(feedProvider);
    final bool isSupervisor = user?.isSupervisor ?? true;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: HomeAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: IndexedStack(
          index: feedController.tabIndex,
          children: [
            FeedContent(controller: feedController), // 0
            const DashboardScreen(), // 1
            const SizedBox.shrink(), // 2 (Botão publicar)
            isSupervisor ? const AlertAdminScreen() : const AlertUserScreen(), // 3
          ],
        ),
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: feedController.tabIndex,
        isSupervisor: isSupervisor,
        notificationCount: feedController.notifications,
        onItemTapped: (index) {
          if (index == 2) {
            _handlePublish(user);
          } else {
            feedController.changeTab(index);
          }
        },
      ),
    );
  }

  void _handlePublish(dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PublishModal(
        onPublish: (content, files) async {
          // 🚀 Chama o controller e aguarda a criação
          await ref.read(feedProvider).publish(
                content: content,
                attachments: files,
                currentUser: user,
              );
          
          // 🚀 Fecha o modal somente após terminar
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
}
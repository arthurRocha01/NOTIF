import 'package:flutter/material.dart';
import 'package:notif_app/features/alerts/screen/supervisor_home_screen.dart';
import 'package:notif_app/features/alerts/screen/alerts_central_screen.dart';
import 'package:notif_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';
import 'package:notif_app/features/home/widgets/home_app_bar.dart';
import '../widgets/home_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0: Notificações, 1: Dashboard, 2: Criar Alerta
  int _selectedTab = 0;

  void _onTabTapped(int index) {
    setState(() => _selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      drawer: const AppDrawer(),
      appBar: const HomeAppBar(),
      body: IndexedStack(
        index: _selectedTab,
        children: const [
          SupervisorHomeScreen(), // Index 0
          DashboardScreen(),      // Index 1
          AlertsCentralScreen(),  // Index 2
        ],
      ),
      bottomNavigationBar: HomeBottomNav(
        selectedIndex: _selectedTab,
        notificationCount: 2,
        onItemTapped: _onTabTapped,
      ),
    );
  }
}



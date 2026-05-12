import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final int notificationCount;
  final ValueChanged<int> onItemTapped;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.notificationCount,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF0F172A),
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$notificationCount'),
              isLabelVisible: notificationCount > 0,
              backgroundColor: const Color(0xFFEF4444),
              child: const Icon(LucideIcons.bell),
            ),
            label: 'Notificações',
          ),
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}

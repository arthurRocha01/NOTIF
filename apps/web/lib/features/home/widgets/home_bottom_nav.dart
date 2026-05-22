import 'package:flutter/material.dart';
import 'package:notif_app/shared/widgets/custom_navbar.dart';

class HomeBottomNav extends StatelessWidget {
  /// pageIndex: 0=Alertas, 1=Dashboard, 2=Painel (supervisor only)
  final int pageIndex;
  final bool isSupervisor;
  final Function(int navIndex) onItemTapped;
  final int notificationCount;

  const HomeBottomNav({
    super.key,
    required this.pageIndex,
    required this.isSupervisor,
    required this.onItemTapped,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSupervisor) return const SizedBox.shrink();

    return CustomNavbar(
      selectedIndex: pageIndex.clamp(0, 2),
      items: [
        NavItemData(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: 'Notificações',
          badgeCount: notificationCount,
        ),
        const NavItemData(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard,
          label: 'Dashboard',
        ),
        const NavItemData(
          icon: Icons.warning_amber_rounded,
          activeIcon: Icons.report_problem,
          label: 'Painel',
        ),
      ],
      onTap: onItemTapped,
    );
  }
}

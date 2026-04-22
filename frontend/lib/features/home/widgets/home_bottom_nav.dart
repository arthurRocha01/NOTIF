import 'package:flutter/material.dart';
import 'package:notif_app/shared/widgets/custom_navbar.dart';

class HomeBottomNav extends StatelessWidget {
  /// pageIndex: 0=Feed, 1=Dashboard, 2=Alerts
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

  /// Mapeia pageIndex (lógico) → índice visual na CustomNavbar
  int get _currentNavIndex {
    if (isSupervisor) {
      // Supervisor: [Home=0, Publicar=1, Dashboard=2, Alertas=3]
      switch (pageIndex) {
        case 1:
          return 2; // Dashboard
        case 2:
          return 3; // Alertas
        default:
          return 0; // Feed
      }
    } else {
      // Employee: [Home=0, Publicar=1, Alertas=2]
      return pageIndex == 2 ? 2 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final alertItem = NavItemData(
      icon: Icons.warning_amber_rounded,
      activeIcon: Icons.report_problem,
      label: isSupervisor ? 'Painel' : 'Alertas',
      badgeCount: notificationCount,
    );

    final items = isSupervisor
        ? <NavItemData>[
            const NavItemData(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Início',
            ),
            const NavItemData(
              icon: Icons.add_box_outlined,
              activeIcon: Icons.add_box,
              label: 'Publicar',
            ),
            const NavItemData(
              icon: Icons.dashboard_outlined,
              activeIcon: Icons.dashboard,
              label: 'Dashboard',
            ),
            alertItem,
          ]
        : <NavItemData>[
            const NavItemData(
              icon: Icons.home_outlined,
              activeIcon: Icons.home,
              label: 'Início',
            ),
            const NavItemData(
              icon: Icons.add_box_outlined,
              activeIcon: Icons.add_box,
              label: 'Publicar',
            ),
            alertItem,
          ];

    return CustomNavbar(
      selectedIndex: _currentNavIndex,
      items: items,
      onTap: onItemTapped,
    );
  }
}

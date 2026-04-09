import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  // pageIndex: 0=Feed, 1=Dashboard, 2=Alerts
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

  // Mapeia pageIndex → índice visual na nav bar
  int get _currentNavIndex {
    if (isSupervisor) {
      // Supervisor: [Home=0, Publicar=1, Dashboard=2, Alertas=3]
      switch (pageIndex) {
        case 1: return 2; // Dashboard
        case 2: return 3; // Alertas
        default: return 0; // Feed
      }
    } else {
      // Employee: [Home=0, Publicar=1, Alertas=2]
      return pageIndex == 2 ? 2 : 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF0F172A);

    final alertItem = BottomNavigationBarItem(
      icon: Badge(
        label: Text('$notificationCount'),
        isLabelVisible: notificationCount > 0,
        child: const Icon(Icons.warning_amber_rounded),
      ),
      activeIcon: Badge(
        label: Text('$notificationCount'),
        isLabelVisible: notificationCount > 0,
        child: const Icon(Icons.report_problem),
      ),
      label: isSupervisor ? 'Painel' : 'Alertas',
    );

    final items = isSupervisor
        ? <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Publicar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            alertItem,
          ]
        : <BottomNavigationBarItem>[
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Início',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Publicar',
            ),
            alertItem,
          ];

    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkNavy,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
    );
  }
}

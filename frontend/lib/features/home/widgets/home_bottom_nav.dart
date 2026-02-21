// lib/features/home/widgets/home_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

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
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.darkNavy,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Início'),
          const BottomNavigationBarItem(icon: Icon(LucideIcons.plusSquare, size: 28), label: 'Publicar'),
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$notificationCount'),
              isLabelVisible: notificationCount > 0,
              child: const Icon(LucideIcons.alertTriangle),
            ),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}
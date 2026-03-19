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
        elevation: 0, // Tiramos a sombra padrão para usar o border do Container

        selectedItemColor: const Color(0xFF0F172A), 
        unselectedItemColor: Colors.grey.shade500,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),

        type: BottomNavigationBarType.fixed, // Mantém os labels sempre visíveis

        items: [
          /// 🏠 INÍCIO (Index 0)
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Início',
          ),

          /// 📊 DASHBOARD (Index 1)
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.layoutDashboard),
            label: 'Dashboard',
          ),

          /// ➕ PUBLICAR (Index 2)
          const BottomNavigationBarItem(
            icon: Icon(LucideIcons.plusSquare, size: 26),
            label: 'Publicar',
          ),

          /// 🚨 ALERTAS (Index 3)
          BottomNavigationBarItem(
            icon: Badge(
              label: Text('$notificationCount'),
              isLabelVisible: notificationCount > 0,
              backgroundColor: const Color(0xFFEF4444), // Vermelho vibrante para atenção
              child: const Icon(LucideIcons.bell), // Mudei para Bell para diferenciar do "Aviso"
            ),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final bool isSupervisor;
  final Function(int) onItemTapped;
  final int notificationCount;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.isSupervisor,
    required this.onItemTapped,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const Color darkNavy = Color(0xFF0F172A);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkNavy,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true, // Garante que os nomes apareçam
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined), // Ícone padrão para publicar
          activeIcon: Icon(Icons.add_box),
          label: 'Publicar',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('$notificationCount'),
            isLabelVisible: notificationCount > 0,
            // ⚠️ Ícone de Triângulo de Alerta
            child: const Icon(Icons.warning_amber_rounded),
          ),
          activeIcon: Badge(
            label: Text('$notificationCount'),
            isLabelVisible: notificationCount > 0,
            child: const Icon(Icons.report_problem), // Triângulo preenchido
          ),
          label: isSupervisor ? 'Painel' : 'Alertas',
        ),
      ],
    );
  }
}
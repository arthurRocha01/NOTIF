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
    // Definimos a cor Navy para manter o padrão do app
    const Color darkNavy = Color(0xFF0F172A);

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped, // 👈 Isso repassa o clique para a HomeScreen abrir o modal
      type: BottomNavigationBarType.fixed,
      selectedItemColor: darkNavy,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Início',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard', // 👈 Nome atualizado
        ),
        const BottomNavigationBarItem(
          // Removido o CircleAvatar para padronizar o hover/seleção
          icon: Icon(Icons.add_box_outlined),
          activeIcon: Icon(Icons.add_box),
          label: 'Publicar', // 👈 Nome atualizado
        ),
        BottomNavigationBarItem(
          icon: Badge(
            label: Text('$notificationCount'),
            isLabelVisible: notificationCount > 0,
            // 👈 Ícone de triângulo de alerta adicionado
            child: const Icon(Icons.warning_amber_rounded), 
          ),
          activeIcon: Badge(
            label: Text('$notificationCount'),
            isLabelVisible: notificationCount > 0,
            child: const Icon(Icons.report_problem), // Triângulo preenchido quando ativo
          ),
          label: isSupervisor ? 'Painel' : 'Alertas',
        ),
      ],
    );
  }
}
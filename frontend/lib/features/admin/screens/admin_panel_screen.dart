import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:notif_app/features/admin/modals/create_edit_sector_modal.dart';
import 'package:notif_app/features/admin/modals/create_edit_user_modal.dart';
import 'package:notif_app/features/admin/providers/admin_sector_provider.dart';
import 'package:notif_app/features/admin/providers/admin_user_provider.dart';
import 'package:notif_app/features/admin/screens/admin_dashboard_page.dart';
import 'package:notif_app/features/admin/screens/sectors_management_screen.dart';
import 'package:notif_app/features/admin/screens/users_management_screen.dart';
import 'package:notif_app/shared/layout/app_drawer.dart';
import 'package:notif_app/shared/widgets/home_app_bar.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminUserProvider.notifier).loadUsers();
      ref.read(adminSectorProvider.notifier).loadSectors();
    });
  }

  void _onNavTap(int index) => setState(() => _pageIndex = index);

  Widget? _buildFab() {
    switch (_pageIndex) {
      case 1:
        return FloatingActionButton(
          heroTag: 'fab-users',
          backgroundColor: const Color(0xFF4A6CF7),
          onPressed: () async {
            final ok = await CreateEditUserModal.show(context);
            if (ok == true && mounted) {
              ref.read(adminUserProvider.notifier).loadUsers();
            }
          },
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      case 2:
        return FloatingActionButton(
          heroTag: 'fab-sectors',
          backgroundColor: const Color(0xFF16A34A),
          onPressed: () async {
            await CreateEditSectorModal.show(context);
          },
          child: const Icon(Icons.add, color: Colors.white),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: HomeAppBar(
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _pageIndex,
        children: [
          AdminDashboardPage(
            onNavigateToUsers: () => _onNavTap(1),
            onNavigateToSectors: () => _onNavTap(2),
          ),
          const UsersManagementScreen(),
          const SectorsManagementScreen(),
        ],
      ),
      floatingActionButton: _buildFab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: _onNavTap,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF4A6CF7).withValues(alpha: 0.12),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.layoutDashboard),
            selectedIcon: Icon(LucideIcons.layoutDashboard,
                color: Color(0xFF4A6CF7)),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users),
            selectedIcon:
                Icon(LucideIcons.users, color: Color(0xFF4A6CF7)),
            label: 'Usuários',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.building2),
            selectedIcon:
                Icon(LucideIcons.building2, color: Color(0xFF4A6CF7)),
            label: 'Setores',
          ),
        ],
      ),
    );
  }
}

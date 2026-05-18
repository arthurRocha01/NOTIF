import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/model/user_model.dart';
import 'package:notif_app/core/notifications/notification_service.dart';
import 'package:notif_app/features/admin/screens/admin_panel_screen.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
import 'package:notif_app/features/alerts/providers/alert_provider.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';
import 'package:notif_app/features/sectors/providers/sector_provider.dart';

// Altere para false para restaurar o fluxo normal de login.
const _kTestMode = false;

const _testSupervisor = UserModel(
  id: 'debug-sup-01',
  name: 'Supervisor Teste',
  email: 'supervisor@notif.com',
  sector: 'TI',
  role: UserRole.supervisor,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  runApp(
    ProviderScope(
      overrides: _kTestMode
          ? [
              authProvider.overrideWith((ref) {
                final n = AuthNotifier(
                  ref.read(authServiceProvider),
                  ref.read(tokenStorageProvider),
                  ref.read(sectorServiceProvider),
                  ref.read(alertServiceProvider),
                  ref.read(fcmServiceProvider),
                );
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                n.state = _testSupervisor;
                return n;
              }),
              authInitProvider.overrideWith((_) async {}),
            ]
          : const [],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Widget _resolveHome(dynamic user) {
    if (user == null) return const LoginScreen();
    if (user.isAdmin) return const AdminPanelScreen();
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(authInitProvider);
    final user = ref.watch(authProvider);

    ApiClient.onUnauthorized = () {
      ref.read(authProvider.notifier).logout();
    };

    final theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

    return MaterialApp(
      title: 'Notif App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: init.when(
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => _resolveHome(user),
        data: (_) => _resolveHome(user),
      ),
    );
  }
}

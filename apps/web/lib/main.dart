import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/core/notifications/notification_service.dart';
import 'package:notif_app/features/admin/screens/admin_panel_screen.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';
import 'package:notif_app/features/splash/splash_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Inicializa o serviço de notificações
  await NotificationService().initialize();
  
  // CORREÇÃO: Inicializa a formatação de datas para o padrão brasileiro
  await initializeDateFormatting('pt_BR', null);

  runApp(
    const ProviderScope(
      child: MyApp(),
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
      focusColor: const Color(0xFF3B63E8).withValues(alpha: 0.30),
      hoverColor: const Color(0xFF3B63E8).withValues(alpha: 0.08),
    );

    return MaterialApp(
      title: 'Notif App',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: init.when(
        loading: () => const SplashScreen(),
        error: (_, __) => _resolveHome(user),
        data: (_) => _resolveHome(user),
      ),
    );
  }
}
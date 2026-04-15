import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/core/api/api_client.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';
import 'package:notif_app/features/login/providers/auth_provider.dart';
import 'package:notif_app/features/login/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
        error: (_, __) =>
            user == null ? const LoginScreen() : const HomeScreen(),
        data: (_) =>
            user == null ? const LoginScreen() : const HomeScreen(),
      ),
    );
  }
}

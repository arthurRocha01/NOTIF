import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notif_app/features/alerts/screen/alerts_admin_screen.dart';
import 'package:notif_app/features/home/screen/home_screen.dart';

import 'package:notif_app/features/login/screen/login_screen.dart';
// Import da sua tela real
import 'package:notif_app/features/login/providers/auth_provider.dart';

void main() {
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
    // O segredo da reatividade: se o estado do authProvider mudar, 
    // o Flutter reconstrói o MaterialApp inteiro.
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Notif App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      // Lógica de Roteamento Automático:
      // Se não houver usuário logado (null), mostra a tela de Login.
      // Se houver (UserModel), mostra a Home já configurada.
      home: user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
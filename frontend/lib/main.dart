import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- 1. Adicione este import
import 'package:notif_app/features/home/screen/home_screen.dart';

// import 'features/login/login_screen.dart'; // Você pode comentar ou apagar se não for usar agora

void main() {
  runApp(
    // <-- 2. Envolva o NotifApp com o ProviderScope
    const ProviderScope(
      child: NotifApp(),
    ),
  );
}

class NotifApp extends StatelessWidget {
  const NotifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOTIF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      // AQUI É A MUDANÇA: Mandando abrir a HomeScreen
      home: const HomeScreen(),
    );
  }
}
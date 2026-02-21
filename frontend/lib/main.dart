import 'package:flutter/material.dart';
// Importa a tela que acabamos de criar
// import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';

void main() {
  runApp(const NotifApp());
}

class NotifApp extends StatelessWidget {
  const NotifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOTIF Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      // AQUI É O SEGREDO: Mandando abrir a LoginScreen
      home: const HomeScreen(),
    );
  }
}

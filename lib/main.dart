import 'package:flutter/material.dart';
import 'package:life_vault/splash_screen.dart';

void main() {
  runApp(const LifeVaultApp());
}

class LifeVaultApp extends StatelessWidget {
  const LifeVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeVault',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Enforce Dark Mode initially
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF020617), // Deepest Slate/Black
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6), // Bright Blue seed
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A), // Card/Surface color
          onSurface: const Color(0xFFF1F5F9), // White/Grey text
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/home/presentation/pages/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/home/presentation/providers/ip_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const SmartHomeApp(),
    ),
  );
}

class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Digital Twin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).copyWith(
          displayMedium: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: Colors.white,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF0A0A0A), // Gris neutre ultra-sombre
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 1),
          ),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Aby
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SKPI App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // 1. Warna Latar Aplikasi (Abu-abu kebiruan sangat muda)
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), 
        
        // 2. Skema Warna Utama (Biru khas desain web)
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),

        // 3. Gaya Card untuk layout Bento Grid
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2, // Bayangan sangat tipis agar elegan
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Ujung melengkung modern
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),

        // 4. Gaya Tombol Utama
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white, // Warna teks di dalam tombol
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
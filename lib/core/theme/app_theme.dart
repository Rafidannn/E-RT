import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama sesuai desain kamu
  static const Color primaryGreen = Color(0xFF2D4B1E);
  static const Color accentOrange = Color(0xFFFFA500);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: Colors.white,

      // Mengatur font default atau warna teks
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentOrange,
      ),

      // Pengaturan default untuk AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      // Pengaturan default untuk tombol (Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentOrange,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
      ),
    );
  }
}

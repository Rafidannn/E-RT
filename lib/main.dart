import 'package:ert/pages/dashboard/dashboard_admin.dart';
import 'package:ert/pages/dashboard/dashboard_user.dart';
import 'package:ert/pages/pengumuman/riwayat_pengumuman_page.dart';
import 'package:ert/pages/warga/warga_page.dart';
import 'package:flutter/material.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart'; // Import file register lu

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(), // Daftarin di sini
        '/dashboard_admin': (context) => const DashboardAdminPage(),
        '/dashboard' : (context) => const DashboardUserPage(),
        '/manage_warga' : (context) => const WargaPage(),
        '/riwayat_pengumuman' : (context) => const RiwayatPengumumanPage()
      },
    );
  }
}
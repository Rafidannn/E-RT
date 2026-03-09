import 'package:ert/pages/dashboard/dashboard_page.dart';
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
        '/dashboard': (context) => const DashboardPage()
      },
    );
  }
}
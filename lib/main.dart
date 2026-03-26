import 'package:ert/pages/iuran/riwayat_iuran_page.dart';
import 'package:ert/pages/pengumuman/pengumuman_page.dart';
import 'package:ert/pages/laporan/laporan_page.dart';
import 'package:ert/pages/profil/profil_admin_page.dart';
import 'package:flutter/material.dart';

// Import Auth
import 'package:ert/pages/auth/login_page.dart';
import 'package:ert/pages/auth/register_page.dart';

// Import Dashboard
import 'package:ert/pages/dashboard/dashboard_admin.dart';
import 'package:ert/pages/dashboard/dashboard_user.dart';

// Import Verifikasi
import 'package:ert/pages/verifikasi/verifikasi_page.dart';

// Import Warga & Keluarga
import 'package:ert/pages/warga/warga_page.dart';
import 'package:ert/pages/warga/tambah_warga_page.dart';
import 'package:ert/pages/keluarga/list_keluarga_page.dart';
// Note: DetailKeluargaPage gak masuk routes karena butuh parameter ID

// Import Jumantik
import 'package:ert/pages/jumantik/jumantik_page.dart';
import 'package:ert/pages/jumantik/riwayat_jumantik_page.dart';

// Import Iuran & Pengumuman
import 'package:ert/pages/iuran/input_iuran_page.dart'; // Pastiin nama class-nya bener RiwayatIuranPage kalau itu isinya riwayat
import 'package:ert/pages/iuran/verifikasi_pembayaran_page.dart';
import 'package:ert/pages/pengumuman/riwayat_pengumuman_page.dart';
import 'package:ert/pages/pengumuman/daftar_pengumuman_page.dart';

// Import Posyandu
import 'package:ert/pages/posyandu/posyandu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-RT App',
      initialRoute: '/login',
      routes: {
        // AUTH
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // DASHBOARD
        '/dashboard_admin': (context) => const DashboardAdminPage(),
        '/dashboard': (context) => const DashboardUserPage(),
        '/verifikasi': (context) => const VerifikasiPage(),

        // WARGA & KELUARGA
        '/manage_warga': (context) => const WargaPage(),
        '/add_warga': (context) => const TambahWargaPage(),
        '/manage_keluarga': (context) => const ListKeluargaPage(),

        // IURAN
        '/manage_iuran': (context) => const RiwayatIuranUserPage(idKeluarga: "4"), // Pastiin import path-nya bener ke file riwayat
        '/input_iuran_user': (context) => const InputIuranPage(),
        '/verifikasi_pembayaran': (context) => const VerifikasiPembayaranPage(),

        // JUMANTIK
        '/jumantik': (context) => const JumantikPage(),
        '/riwayat_jumantik': (context) => const RiwayatJumantikPage(),

        // POSYANDU
        '/posyandu': (context) => const PosyanduPage(),

        // PENGUMUMAN
        '/riwayat_pengumuman': (context) => const RiwayatPengumumanPage(),
        '/pengumuman_page' : (context) => const PengumumanPage(),
        '/daftar_pengumuman' : (context) => const DaftarPengumumanPage(),

        // LAPORAN / REKAP
        '/rekap': (context) => const LaporanPage(),
        
        // PROFIL
        '/profil_admin': (context) => const ProfilAdminPage(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Buat sesi nama

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  String _namaUser = "Admin";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Ngambil nama yang lu simpen pas login tadi
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaUser = prefs.getString('nama_user') ?? "Admin";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 1. HEADER IJO & SEARCH BAR
                _buildHeader(_namaUser),

                // 2. STATISTIK HORIZONTAL (SCROLLABLE)
                const SizedBox(height: 20),
                _buildHorizontalStats(),

                // 3. CHART RASIO KELUARGA
                const SizedBox(height: 20),
                _buildRasioKeluargaCard(),

                // 4. MENU GRID
                const SizedBox(height: 20),
                _buildMenuGrid(context),

                const SizedBox(height: 120), // Biar gak ketutup navbar
              ],
            ),
          ),

          // 5. CUSTOM BOTTOM NAVBAR
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomNavbar()
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String nama) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.settings_outlined, color: Colors.white),
              Text(
                'Selamat Datang, $nama', // Nyapa nama asli lu
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            decoration: InputDecoration(
              hintText: "Search Bar",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildStatItem(Icons.people_outline, "40", "Total Warga"),
          _buildStatItem(Icons.home_outlined, "40", "Total Keluarga"),
          _buildStatItem(Icons.account_balance_wallet_outlined, "1.525.000", "Saldo Iuran"),
          _buildStatItem(Icons.favorite_border, "40", "Lansia Terdata"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black87, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRasioKeluargaCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rasio Keluarga", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildLegendItem(const Color(0xFF2D4B1E), "Mandiri"),
                    _buildLegendItem(const Color(0xFF8CAF5D), "Madya"),
                    _buildLegendItem(Colors.orange, "Prasejahtera"),
                  ],
                ),
              ),
              Container(
                height: 100, width: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2D4B1E), width: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(child: Text("📅 12 Januari 2026", style: TextStyle(color: Colors.grey))),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 15, height: 15, color: color),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
        children: [
          // TOMBOL DATA WARGA SUDAH AKTIF
          _buildMenuIcon(context, Icons.person_outline, "Data Warga", '/manage_warga'),
          _buildMenuIcon(context, Icons.people_outline, "Data Keluarga", '/manage_keluarga'),
          _buildMenuIcon(context, Icons.account_balance_wallet_outlined, "Input Iuran", '/manage_iuran'),
          _buildMenuIcon(context, Icons.verified_user_outlined, "Verifikasi User", '/verifikasi'),
          _buildMenuIcon(context, Icons.home_work_outlined, "Posyandu", '/posyandu'),
          _buildMenuIcon(context, Icons.assignment_outlined, "Laporan Jumantik", '/jumantik'),
          _buildMenuIcon(context, Icons.campaign_outlined, "Buat Pengumuman", '/riwayat_pengumuman'),
          _buildMenuIcon(context, Icons.description_outlined, "Rekap Laporan", '/rekap'),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route), // Pindah halaman
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF8CAF5D),
                borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 5),
          Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home, color: Colors.white, size: 30),
          Icon(Icons.people_outline, color: Colors.white70),
          Icon(Icons.account_balance_wallet_outlined, color: Colors.white70),
          Icon(Icons.favorite_outline, color: Colors.white70),
          Icon(Icons.person_outline, color: Colors.white70),
        ],
      ),
    );
  }
}
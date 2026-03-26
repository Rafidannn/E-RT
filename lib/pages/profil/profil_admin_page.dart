import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profil_features.dart'; // IMPORT FILE FITUR

class ProfilAdminPage extends StatefulWidget {
  const ProfilAdminPage({super.key});

  @override
  State<ProfilAdminPage> createState() => _ProfilAdminPageState();
}

class _ProfilAdminPageState extends State<ProfilAdminPage> {
  String _namaUser = "Memuat...";
  String _roleUser = "ADMIN";
  String _nikUser = "admin_001";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaUser = prefs.getString('nama_user') ?? "Admin RT";
      _roleUser = (prefs.getString('role') ?? "admin").toUpperCase();
      _nikUser = prefs.getString('nik_user') ?? "ID_001";
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red))
          ),
        ],
      )
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); 
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _navigateToAndRefresh(Widget widgetPage) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => widgetPage));
    if (result == true) {
       // Refresh nama user from shared pref if updated
       _loadProfileData(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // Soft clean background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3624)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Executive Profile",
          style: TextStyle(color: Color(0xFF1B3624), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF1B3624)),
            onPressed: () => _navigateToAndRefresh(const PengaturanNotifikasiPage()),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // Avatar Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1C7B2), // Peachy color like the image
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFFF1C7B2).withValues(alpha: 0.5), blurRadius: 15, offset: const Offset(0, 8)),
                            ]
                          ),
                          child: const Icon(Icons.person, size: 70, color: Color(0xFF1B3624)),
                        ),
                        Positioned(
                          bottom: -5,
                          right: -5,
                          child: InkWell(
                            onTap: () => _navigateToAndRefresh(EditProfilPage(currentName: _namaUser, currentNik: _nikUser)),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1B3624), // Dark Green
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.edit, color: Colors.white, size: 14),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Name and Badge
                  Text(_namaUser, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B3624))),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B3624),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_roleUser == 'ADMIN' ? "ADMIN / KETUA RT" : "WARGA RT", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 5),
                  Text("Admin ID: #$_nikUser", style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  
                  const SizedBox(height: 30),
                  
                  // Primary Account Info
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5)),
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Informasi Akun Utama", style: TextStyle(color: Color(0xFF1B3624), fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             const Text("Username (NIK)", style: TextStyle(color: Colors.black87, fontSize: 13)),
                             Text(_nikUser, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                             Text("Terdaftar Sejak", style: TextStyle(color: Colors.black87, fontSize: 13)),
                             Text("Sistem ERT", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Account Settings
                  _buildSectionHeader("PENGATURAN AKUN"),
                  _buildMenuCard([
                    _buildMenuItem(Icons.person_outline, "Edit Profil", () => _navigateToAndRefresh(EditProfilPage(currentName: _namaUser, currentNik: _nikUser))),
                    _buildDivider(),
                    _buildMenuItem(Icons.lock_outline, "Keamanan & Kata Sandi", () => _navigateToAndRefresh(UbahPasswordPage(currentNik: _nikUser))),
                    _buildDivider(),
                    _buildMenuItem(Icons.notifications_none_outlined, "Pengaturan Notifikasi", () => _navigateToAndRefresh(const PengaturanNotifikasiPage()), showBottomBorder: false),
                  ]),
                  
                  const SizedBox(height: 25),
                  
                  // Admin Tools
                  if (_roleUser == 'ADMIN') ...[
                    _buildSectionHeader("ALAT ADMIN"),
                    _buildMenuCard([
                      _buildMenuItem(Icons.storage_outlined, "Cadangkan Data (Excel/CSV)", () => AdminTools.exportDataCsv(context)),
                      _buildDivider(),
                      _buildMenuItem(Icons.history_outlined, "Log Aktivitas", () => _navigateToAndRefresh(const LogAktivitasPage()), showBottomBorder: false),
                    ]),
                    const SizedBox(height: 25),
                  ],
                  
                  // Help Center
                  _buildSectionHeader("PUSAT BANTUAN"),
                  _buildMenuCard([
                    _buildMenuItem(Icons.description_outlined, "Syarat & Ketentuan", () => _navigateToAndRefresh(const SyaratKetentuanPage())),
                    _buildDivider(),
                    _buildMenuItem(Icons.help_outline, "Hubungi Pengembang", () => AdminTools.openDevWhatsapp(context), showBottomBorder: false),
                  ]),
                  
                  const SizedBox(height: 35),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD32F2F), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout, color: Color(0xFFD32F2F), size: 20),
                      label: const Text("Keluar dari Akun", style: TextStyle(color: Color(0xFFD32F2F), fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Footer Text
                  const Text(
                    "E-RT DIGITAL SYSTEM v2.4.0\nPOWERED BY CHANCELLOR ARCHIDAL ENGINE",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 9, letterSpacing: 1, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  
                  const SizedBox(height: 120), // Navbar space
                ],
              ),
            ),
          ),
          
          // Custom Bottom Floating Navbar
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavbar(context)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          style: const TextStyle(color: Color(0xFF1B3624), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.2),
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
           BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5)),
        ]
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool showBottomBorder = true}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF1B3624), size: 22),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w500))),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 55, endIndent: 20);
  }

  Widget _buildBottomNavbar(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF2D4B1E), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(icon: const Icon(Icons.home_outlined, color: Colors.white70, size: 28), onPressed: () => Navigator.pushNamedAndRemoveUntil(context, _roleUser == 'ADMIN' ? '/dashboard_admin' : '/dashboard', (route) => false)),
          IconButton(icon: const Icon(Icons.people_outline, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/manage_warga')),
          IconButton(icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/manage_iuran')),
          const Icon(Icons.person, color: Colors.white, size: 28), // Active solid
        ],
      ),
    );
  }
}

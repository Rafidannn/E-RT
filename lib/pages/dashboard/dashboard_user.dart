import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import '../iuran/user_riwayat_iuran_page.dart';
import '../laporan/user_laporan_page.dart';
import '../surat/user_surat_page.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  String _namaUser = "User";
  String _statusIuran = "Mengecek...";
  List<dynamic> _listPengumuman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String nik = prefs.getString('nik_user') ?? '';
      _namaUser = prefs.getString('nama_user') ?? 'User';

      final res = await Future.wait([
        ApiService.post(ApiUrl.getIuranByUser, {'nik': nik}),
        ApiService.get(ApiUrl.pengumuman),
      ]);

      if (mounted) {
        setState(() {
          // Status Iuran
          if (res[0]['status'] == true) {
            List iurans = res[0]['data'];
            int tunggakan = iurans.where((i) => i['status'] != 'lunas').length;
            _statusIuran = tunggakan == 0 ? "LUNAS" : "TUNGGAKAN $tunggakan";
          } else {
            _statusIuran = "Bebas Iuran";
          }

          // List Pengumuman
          if (res[1]['status'] == true) {
            _listPengumuman = res[1]['data'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2B14), 
      body: RefreshIndicator(
        onRefresh: _fetchData,
        color: const Color(0xFF0C2B14),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Stack(
            children: [
              // 1. Background Hijau Gelap Header
              Container(
                height: 300,
                color: const Color(0xFF0C2B14),
              ),
              
              // 2. Background Beige Melengkung
              Positioned.fill(
                top: 210, // Menentukan di mana lekukan mulai muncul
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F7F1),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(55)),
                  ),
                  child: Stack(
                    children: [
                      // WATERMARK MENGGUNAKAN GAMBAR LOGO
                      Positioned(
                        top: 80,
                        left: 0, right: 0,
                        child: Opacity(
                          opacity: 0.1,
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_ert.png', 
                              height: 250,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/logo.png', // Fallback
                                  height: 250,
                                  errorBuilder: (c,e,s) => const SizedBox(),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 3. Konten Berjalan (Semua Elemen)
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildDarkHeader(),
                    
                    // Card Posyandu langsung numpang di atas lekukan
                    _buildPosyanduCard(),
                    const SizedBox(height: 20),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(child: _buildStatusIuranCard()),
                          const SizedBox(width: 15),
                          Expanded(child: _buildStatusKesehatanCard()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    _buildLayananWargaGrid(),
                    const SizedBox(height: 25),
                    _buildPengumumanList(),
                    const SizedBox(height: 120), // Spasi Navbar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNav(),
    );
  }

  Widget _buildDarkHeader() {
    return Padding(
      // Padding dibikin lebih rapet atas dan bawah biar nggak terlalu makan tempat/ngeblock layout
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFFF09A32), borderRadius: BorderRadius.circular(20)),
                child: const Text("Akun Terverifikasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.settings_outlined, color: Colors.white, size: 26),
              Flexible(
                child: Text(
                  "Selamat Datang, $_namaUser",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blueAccent,
                  ),
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.white, size: 26),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Search Bar",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: const Icon(Icons.mic, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPosyanduCard() {
    return Container(
      // Margin diubah agar numpang pas elegan di batas lekukan warna
      margin: const EdgeInsets.only(left: 22, right: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFF8CAF5D), shape: BoxShape.circle),
            child: const Icon(Icons.calendar_month, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Jadwal Posyandu", style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                Text("Besok, 08:00 WIB", style: TextStyle(color: Color(0xFF0F2C15), fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatusIuranCard() {
    bool isLunas = _statusIuran == "LUNAS" || _statusIuran == "Bebas Iuran";
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.receipt_long, color: Colors.green, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.greenAccent.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(15)),
                child: const Text("TERBARU", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 15),
          const Text("Status Iuran", style: TextStyle(color: Colors.grey, fontSize: 11)),
          Text(_statusIuran, style: TextStyle(color: isLunas ? Colors.green : Colors.red, fontSize: 16, fontWeight: FontWeight.w900)),
          const Text("Hingga Bulan Ini", style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildStatusKesehatanCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF1B3A5A).withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF1B3A5A), size: 20),
          ),
          const SizedBox(height: 15),
          const Text("Kesehatan Keluarga", style: TextStyle(color: Colors.grey, fontSize: 11)),
          const Text("Kondisi Sehat", style: TextStyle(color: Color(0xFF1B3A5A), fontSize: 15, fontWeight: FontWeight.w900)),
          const Text("Jentik: Tidak Ada", style: TextStyle(color: Colors.blueGrey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildLayananWargaGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.grid_view_rounded, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text("Layanan Warga", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A2A22))),
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9, // sedikit kotak persegi panjang
            children: [
              _buildLayananIcon(Icons.payments_outlined, "Bayar Iuran", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserRiwayatIuranPage()));
              }),
              _buildLayananIcon(Icons.campaign_outlined, "Lapor RT", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserLaporanPage()));
              }),
              _buildLayananIcon(Icons.description_outlined, "Surat Pengantar", () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const UserSuratPage()));
              }),
              _buildLayananIcon(Icons.calendar_month_outlined, "Agenda RT", () {}),
              _buildLayananIcon(Icons.menu_book_outlined, "Panduan", () {}),
              _buildLayananIcon(Icons.family_restroom_rounded, "Info Keluarga", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLayananIcon(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF7CB342), size: 30),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2C3E35))),
          ],
        ),
      ),
    );
  }

  Widget _buildPengumumanList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.article_outlined, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text("Pengumuman Terkini", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1A2A22))),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pengumuman_page'),
                child: const Text("Lihat Semua", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF7CB342))),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (_listPengumuman.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada pengumuman...")))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _listPengumuman.length > 3 ? 3 : _listPengumuman.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final Map item = _listPengumuman[index];
                String tag = item['kategori']?.toString().toUpperCase() ?? 'UMUM';
                
                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      // Gambar di kiri
                      Container(
                        width: 100, height: 100,
                        color: tag == "UMUM" ? Colors.amber.shade200 : Colors.blue.shade100,
                        child: const Icon(Icons.featured_play_list_outlined, size: 40, color: Colors.black26),
                      ),
                      // Teks
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(10)),
                                    child: Text(tag, style: TextStyle(color: Colors.orange.shade800, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                  Text(item['tanggal'] ?? '15 Aug', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item['judul'] ?? 'Judul Pengumuman',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text("Area: ${item['lokasi'] ?? 'Taman RT'}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // BOTTOM NAV CUSTOM (Mirip desain)
  Widget _buildCustomBottomNav() {
    return Container(
       height: 90, // Taller size to accommodate absolute positioning via stack later if we wanted, but let's use a clever padding
       color: const Color(0xFFF9F7F1), // Warna body krem buat matching lekukan bawah
       child: Stack(
         clipBehavior: Clip.none,
         alignment: Alignment.bottomCenter,
         children: [
           // The dark green actual bar
           Container(
             height: 70,
             decoration: const BoxDecoration(
               color: Color(0xFF0C2B14),
               borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
             ),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 const SizedBox(width: 80), // Space for Home Left Group
                 IconButton(icon: const Icon(Icons.groups_outlined, color: Colors.white, size: 30), onPressed: () {}),
                 IconButton(
                     icon: const Icon(Icons.person_outline, color: Colors.white, size: 30), 
                     onPressed: () {
                         Navigator.pushNamed(context, '/profil'); // Misal route ke profil user
                     }
                 ),
               ],
             ),
           ),
           // Floating Home Hitbox (melayang di sebelah kiri)
           Positioned(
             left: 30,
             bottom: 10, // overlap di atas hijau gelap
             child: Column(
               children: [
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(
                     color: const Color(0xFF7CB342),
                     shape: BoxShape.circle,
                     border: Border.all(color: Colors.white, width: 4), // Border putih elegan
                   ),
                   child: const Icon(Icons.home_outlined, color: Colors.white, size: 28),
                 ),
                 const SizedBox(height: 3),
                 const Text("Home", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
               ],
             ),
           ),
         ],
       ),
    );
  }
}

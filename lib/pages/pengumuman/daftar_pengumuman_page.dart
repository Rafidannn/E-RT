import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'detail_pengumuman_page.dart';

class DaftarPengumumanPage extends StatefulWidget {
  const DaftarPengumumanPage({super.key});

  @override
  State<DaftarPengumumanPage> createState() => _DaftarPengumumanPageState();
}

class _DaftarPengumumanPageState extends State<DaftarPengumumanPage> {
  List<dynamic> _listPengumuman = [];
  bool _isLoading = true;

  // Dummy Fallback if API is empty
  final List<Map<String, dynamic>> _dummyData = [
    {
      "id": "1",
      "judul": "Rapat Warga Bulan Agustus: Bahas Keamanan Lingkungan",
      "tanggal": "18 Agustus 2026",
      "waktu": "19:30 WIB",
      "pembuat": "Admin RT 05",
      "kategori": "TERBARU",
      "isi": "Bapak/Ibu warga RT 05 yang terhormat...\n\nAgenda utama rapat kali ini adalah pembahasan komprehensif mengenai strategi keamanan lingkungan (Siskamling)...",
      "lokasi": "Balai Warga RT 05, Samping Musholla Al-Ikhlas",
      "image": const Color(0xFF6B7F68), // Placeholder background color
    },
    {
      "id": "2",
      "judul": "Jadwal Posyandu Balita & Lansia Minggu Ini",
      "tanggal": "15 Agustus 2026",
      "waktu": "08:00 WIB",
      "pembuat": "Kader Posyandu",
      "kategori": "KESEHATAN",
      "isi": "Kegiatan posyandu rutin bulan Agustus untuk balita dan lansia.",
      "lokasi": "Posko Posyandu Cempaka",
      "image": const Color(0xFF90B4CE),
    },
    {
      "id": "3",
      "judul": "Kerja Bakti Bersama: Perbaikan Selokan Musim Hujan",
      "tanggal": "14 Agustus 2026",
      "waktu": "07:00 WIB",
      "pembuat": "Pengurus RT 05",
      "kategori": "LINGKUNGAN",
      "isi": "Menghadapi musim hujan, dimohon kehadiran warga...",
      "lokasi": "Sepanjang Jalan Utama RT 05",
      "image": const Color(0xFFE8D0B3),
    },
     {
      "id": "4",
      "judul": "Pendaftaran Bansos Tahap III Telah Dibuka",
      "tanggal": "10 Agustus 2026",
      "waktu": "09:00 WIB",
      "pembuat": "Sekretaris RT",
      "kategori": "INFO",
      "isi": "Pendaftaran bansos dibuka sampai tanggal 20 Agustus.",
      "lokasi": "Rumah Pak RT",
      "image": const Color(0xFF869CA9),
    }
  ];

  @override
  void initState() {
    super.initState();
    _fetchPengumuman();
  }

  Future<void> _fetchPengumuman() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiUrl.pengumuman);
      if (res['status'] == true && res['data'] != null && (res['data'] as List).isNotEmpty) {
        final rawData = res['data'] as List;
        setState(() {
          _listPengumuman = rawData.map((e) {
             return {
               "id": e["id_pengumuman"]?.toString() ?? e["id"]?.toString() ?? "0",
               "judul": e["judul"] ?? "Pengumuman",
               "tanggal": e["tanggal"] ?? "-",
               "waktu": e["waktu"] ?? "08:00 WIB",
               "pembuat": e["pembuat"] ?? "Admin RT",
               "kategori": e["kategori"] ?? "INFO",
               "isi": e["isi"] ?? "Format detail belum ditambahkan.",
               "lokasi": e["lokasi"] ?? "Balai Warga",
               "image": (e["foto"] != null && e["foto"] != "") ? "${ApiUrl.baseUrl}/uploads/${e['foto']}" : const Color(0xFF6B7F68), // Placeholder custom API
             };
          }).toList();
        });
      } else {
        // Jika data dari api kosong, fallback ke list dummy buat preview UX
        setState(() {
          _listPengumuman = _dummyData;
        });
      }
    } catch (e) {
      debugPrint("Error fetching pengumuman: $e");
      setState(() {
        _listPengumuman = _dummyData;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF6), // Light green-ish white background
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF14301C)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_listPengumuman.isNotEmpty) ...[
                    // Highlight Card (Top Item)
                    _buildHighlightCard(_listPengumuman.first),
                    const SizedBox(height: 25),
                  ],
                  
                  // Kabar Tetangga Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Kabar Tetangga",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          "Lihat Semua",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // List Cards
                  if (_listPengumuman.length > 1)
                     ListView.builder(
                       shrinkWrap: true,
                       physics: const NeverScrollableScrollPhysics(),
                       padding: const EdgeInsets.symmetric(horizontal: 20),
                       itemCount: _listPengumuman.length - 1,
                       itemBuilder: (context, index) {
                         final item = _listPengumuman[index + 1];
                         return _buildListCard(item);
                       },
                     ),
                     
                  const SizedBox(height: 100), // Bottom padding for navbar
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavbar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7FCF6),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Pengumuman RT",
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 18),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black87),
          onPressed: () {
            showSearch(
              context: context,
              delegate: PengumumanSearchDelegate(
                allData: _listPengumuman,
                onCardTap: (item) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPengumumanPage(pengumumanData: item)));
                }
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHighlightCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPengumumanPage(pengumumanData: item)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 320,
        decoration: BoxDecoration(
          color: item['image'] is Color ? item['image'] : const Color(0xFF6B7F68),
          image: item['image'] is String ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover) : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
          ]
        ),
        child: Stack(
          children: [
            // Dark gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(20),
                 gradient: LinearGradient(
                   begin: Alignment.topCenter,
                   end: Alignment.bottomCenter,
                   colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.8)],
                 )
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['kategori'] ?? "TERBARU",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  
                  // Text Content at Bottom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subtitle / Watermark (optional)
                      const Text(
                        "COMMUNITY",
                        style: TextStyle(color: Colors.white60, fontSize: 30, letterSpacing: 2, fontWeight: FontWeight.w300, height: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item['judul'] ?? 'Pengumuman',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text(item['tanggal'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          const SizedBox(width: 15),
                          const Icon(Icons.access_time_outlined, color: Colors.white70, size: 14),
                          const SizedBox(width: 5),
                          Text(item['waktu'] ?? '10:00 WIB', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPengumumanPage(pengumumanData: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5)
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: item['image'] is Color ? item['image'] : const Color(0xFFD6E3D1),
                image: item['image'] is String ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover) : null,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  if (item['kategori'] != null && item['kategori'] != "LINGKUNGAN")
                    Positioned(
                      top: 15,
                      left: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF71F7C6), // Mint green badge
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['kategori'],
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Text Details
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['judul'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: Colors.black54, size: 14),
                      const SizedBox(width: 5),
                      Text(item['tanggal'] ?? '', style: const TextStyle(color: Colors.black87, fontSize: 11)),
                      const SizedBox(width: 15),
                      const Icon(Icons.access_time_outlined, color: Colors.black54, size: 14),
                      const SizedBox(width: 5),
                      Text(item['waktu'] ?? '08:00 WIB', style: const TextStyle(color: Colors.black87, fontSize: 11)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             _buildBottomNavItem(Icons.home_outlined, "BERANDA", false, '/dashboard_admin'),
             _buildBottomNavItem(Icons.calendar_month_outlined, "KEGIATAN", true, null),
             _buildBottomNavItem(Icons.people_outline, "WARGA", false, '/manage_warga'),
             _buildBottomNavItem(Icons.person_outline, "PROFIL", false, null),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive, String? routeName) {
    Widget itemWidget;
    if (isActive) {
      itemWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF14301C), // Dark green background
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else {
      itemWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (routeName != null) {
          if (label == "BERANDA") {
            Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
          } else {
            Navigator.pushNamed(context, routeName);
          }
        } else if (!isActive) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Halaman $label belum tersedia')));
        }
      },
      borderRadius: BorderRadius.circular(30),
      child: itemWidget,
    );
  }
}

class PengumumanSearchDelegate extends SearchDelegate {
  final List<dynamic> allData;
  final Function(dynamic) onCardTap;

  PengumumanSearchDelegate({required this.allData, required this.onCardTap});

  @override
  String get searchFieldLabel => "Cari pengumuman...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildList();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildList();
  }

  Widget _buildList() {
    final filteredList = allData.where((item) {
      final judul = (item['judul'] ?? '').toString().toLowerCase();
      final isi = (item['isi'] ?? '').toString().toLowerCase();
      final kategori = (item['kategori'] ?? '').toString().toLowerCase();
      final searchLower = query.toLowerCase();
      return judul.contains(searchLower) || isi.contains(searchLower) || kategori.contains(searchLower);
    }).toList();

    if (filteredList.isEmpty) {
      return const Center(child: Text("Pengumuman tidak ditemukan."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: filteredList.length,
      itemBuilder: (context, index) {
        final item = filteredList[index];
        return GestureDetector(
          onTap: () => onCardTap(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 2))
              ]
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: item['image'] is Color ? item['image'] : const Color(0xFFD6E3D1),
                    image: item['image'] is String ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover) : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['judul'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      Text("${item['tanggal']} • ${item['kategori']}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

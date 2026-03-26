import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'edit_warga_page.dart';
import 'detail_warga_page.dart'; // Import halaman detail yang baru dibuat

class WargaPage extends StatefulWidget {
  const WargaPage({super.key});

  @override
  State<WargaPage> createState() => _WargaPageState();
}

class _WargaPageState extends State<WargaPage> {
  List<dynamic> _listWarga = [];
  List<dynamic> _filteredWarga = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getWarga();
  }

  // --- FUNGSI AMBIL DATA ---
  Future<void> _getWarga() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.getWarga);
      if (response['status'] == 'success') {
        setState(() {
          _listWarga = response['data'];
          _filteredWarga = _listWarga;
        });
      }
    } catch (e) {
      debugPrint("Error Load Warga: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI HAPUS ---
  Future<void> _deleteWarga(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin mau hapus data warga ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        final res = await ApiService.post(ApiUrl.deleteWarga, {'id_warga': id});
        if (res['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data berhasil dihapus"), backgroundColor: Colors.green)
          );
          _getWarga();
        }
      } catch (e) {
        debugPrint("Error Delete: $e");
      }
    }
  }

  // --- FUNGSI SEARCH ---
  void _filterWarga(String query) {
    setState(() {
      _filteredWarga = _listWarga
          .where((warga) =>
      warga['nama'].toLowerCase().contains(query.toLowerCase()) ||
          warga['nik'].contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Watermark ERT Logo
          Positioned.fill(
             top: 250,
             child: Align(
               alignment: Alignment.center,
               child: Opacity(
                 opacity: 0.25,
                 child: Image.asset('assets/images/logo_ert.png', width: 250, fit: BoxFit.contain),
               ),
             ),
          ),
          Column(
            children: [
              // HEADER BAGIAN ATAS (Appbar + Search)
              Container(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
                decoration: const BoxDecoration(
                  color: Color(0xFF3B5629), // Dark green background
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Icon
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(context),
                        ),
                        // Title Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BA54D), // Lighter green
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Data Warga",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Add icon
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                          onPressed: () async {
                            final res = await Navigator.pushNamed(context, '/add_warga');
                            if (res == true) _getWarga();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Thin white line separator
                    const Divider(color: Colors.white54, thickness: 1),
                    const SizedBox(height: 15),
                    // Search Bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterWarga,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Search Bar",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          suffixIcon: Icon(Icons.search, color: Colors.black87),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // TOMBOL FILTER (Menjadi shortcut menuju laman Verifikasi)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: _buildFilterButton(Icons.verified_user_outlined, "Status Verifikasi", () {
                   Navigator.pushNamed(context, '/verifikasi');
                }),
              ),

              // LIST DATA WARGA
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B5629)))
                    : RefreshIndicator(
                        onRefresh: _getWarga,
                        child: _filteredWarga.isEmpty
                            ? const Center(child: Text("Data warga tidak ditemukan"))
                            : ListView.builder(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                                itemCount: _filteredWarga.length,
                                itemBuilder: (context, index) {
                                  final warga = _filteredWarga[index];
                                  return _buildWargaCard(warga);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF8BA54D), // Lighter green
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWargaCard(dynamic warga) {
    String statusKesehatan = (warga['status_kesehatan_khusus'] ?? 'umum').toLowerCase();
    String formattedStatus = 'Umum';
    Color badgeColor = Colors.lightBlue.shade200;
    Color textColor = Colors.black87;

    if (statusKesehatan == 'bumil' || statusKesehatan == 'ibu hamil') {
      formattedStatus = 'Bumil';
      badgeColor = Colors.pinkAccent.shade100;
    } else if (statusKesehatan == 'lansia') {
      formattedStatus = 'Lansia';
      badgeColor = Colors.yellow.shade400;
    } else if (statusKesehatan == 'disabilitas') {
      formattedStatus = 'Disabilitas';
      badgeColor = Colors.red.shade300;
    } else {
      formattedStatus = 'Umum';
      badgeColor = Colors.lightBlue.shade300;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF), // Off-white/cream background as shown in design
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orange Avatar
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFF09635), // Orange color
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Warga Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama : ${warga['nama']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Nik : ${warga['nik'] ?? '-'}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "Badge Status : ",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            formattedStatus,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15), // space for Detail Warga at bottom
                  ],
                ),
              ),
              // Action Icons on the trailing right
              Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditWargaPage(warga: warga)),
                          );
                          if (res == true) _getWarga();
                        },
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF3B5629), size: 22),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _deleteWarga(warga['id_warga'].toString()),
                        child: const Icon(Icons.delete_outline, color: Color(0xFF3B5629), size: 22),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          
          // Detail Warga Text Button Positioned Absolute Bottom Right
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailWargaPage(warga: warga)),
                );
              },
              child: const Text(
                "Detail Warga",
                style: TextStyle(
                  color: Color(0xFFF09635), // Orange to match avatar
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

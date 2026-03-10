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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D4B1E),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF8CAF5D),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text("Data Warga",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
              onPressed: () async {
                final res = await Navigator.pushNamed(context, '/add_warga');
                if (res == true) _getWarga();
              }
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF2D4B1E),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)
              ),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWarga,
              decoration: InputDecoration(
                hintText: "Cari nama atau NIK...",
                suffixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none
                ),
              ),
            ),
          ),

          // 2. TOMBOL FILTER (UI Only)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                _buildFilterButton(Icons.home_outlined, "Blok Rumah"),
                const SizedBox(width: 10),
                _buildFilterButton(Icons.verified_user_outlined, "Status Verifikasi"),
              ],
            ),
          ),

          // 3. LIST DATA
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
                : RefreshIndicator(
              onRefresh: _getWarga,
              child: _filteredWarga.isEmpty
                  ? const Center(child: Text("Data warga tidak ditemukan"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _buildFilterButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8CAF5D),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 5),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildWargaCard(dynamic warga) {
    String statusKesehatan = (warga['status_kesehatan_khusus'] ?? 'umum').toLowerCase();
    Color badgeColor;
    if (statusKesehatan == 'bumil') { badgeColor = Colors.pink; }
    else if (statusKesehatan == 'lansia') { badgeColor = Colors.orange; }
    else if (statusKesehatan == 'disabilitas') { badgeColor = Colors.red; }
    else { badgeColor = Colors.blue; }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                    radius: 25,
                    backgroundColor: badgeColor.withOpacity(0.2),
                    child: Text(
                        warga['nama'][0].toUpperCase(),
                        style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)
                    )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama : ${warga['nama']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Nik : ${warga['nik']}", style: const TextStyle(color: Colors.black87, fontSize: 12)),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: badgeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5)
                        ),
                        child: Text(statusKesehatan.toUpperCase(),
                            style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                // TOMBOL EDIT & DELETE
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Color(0xFF2D4B1E)),
                      onPressed: () async {
                        final res = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditWargaPage(warga: warga)),
                        );
                        if (res == true) _getWarga();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteWarga(warga['id_warga'].toString()),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),
            // --- TULISAN DETAIL WARGA ---
            Align(
              alignment: Alignment.bottomRight,
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
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
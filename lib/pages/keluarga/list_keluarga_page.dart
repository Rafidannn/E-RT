import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'detail_keluarga_page.dart';
import 'edit_keluarga_page.dart';
// import 'edit_keluarga_page.dart'; // Buat filenya nanti kalo perlu

class ListKeluargaPage extends StatefulWidget {
  const ListKeluargaPage({super.key});

  @override
  State<ListKeluargaPage> createState() => _ListKeluargaPageState();
}

class _ListKeluargaPageState extends State<ListKeluargaPage> {
  List<dynamic> _listKeluarga = [];
  List<dynamic> _filteredKeluarga = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getKeluarga();
  }

  // --- AMBIL DATA ---
  Future<void> _getKeluarga() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.getKeluarga);
      if (response['status'] == true) {
        setState(() {
          _listKeluarga = response['data'];
          _filteredKeluarga = _listKeluarga;
        });
      }
    } catch (e) {
      debugPrint("Error Load Keluarga: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- FILTER SEARCH ---
  void _filterKeluarga(String query) {
    setState(() {
      _filteredKeluarga = _listKeluarga
          .where((k) =>
      k['nama_warga'].toLowerCase().contains(query.toLowerCase()) ||
          k['no_kk'].contains(query))
          .toList();
    });
  }

  // --- HAPUS DATA ---
  Future<void> _deleteKeluarga(String id) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin mau hapus data keluarga ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      try {
        // Buat endpoint delete_keluarga.php di backend lu
        // Ganti yang tadinya URL manual jadi:
        final res = await ApiService.post(ApiUrl.deleteKeluarga, {'id_keluarga': id});
        if (res['status'] == true) {
          _getKeluarga();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil dihapus")));
        }
      } catch (e) { debugPrint("Error Delete: $e"); }
    }
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
          decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(20)),
          child: const Text("Data Keluarga", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. SEARCH BAR (STYLE WARGA)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF2D4B1E),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterKeluarga,
              decoration: InputDecoration(
                hintText: "Cari nama KK atau No. KK...",
                suffixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. TOTAL INFO
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total: ${_filteredKeluarga.length} Keluarga", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Icon(Icons.sort, color: Colors.grey),
              ],
            ),
          ),

          // 3. LIST DATA
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
                : RefreshIndicator(
              onRefresh: _getKeluarga,
              child: _filteredKeluarga.isEmpty
                  ? const Center(child: Text("Data tidak ditemukan"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filteredKeluarga.length,
                itemBuilder: (context, index) => _buildKeluargaCard(_filteredKeluarga[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeluargaCard(dynamic item) {
    String ekonomi = (item['status_ekonomi'] ?? 'pra-sejahtera').toLowerCase();
    Color badgeColor = ekonomi == 'mandiri' ? Colors.green : (ekonomi == 'madya' ? Colors.blue : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: InkWell( // <--- TAMBAHKAN INI: Biar satu kartu bisa diklik
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // Navigasi lewat klik kartu langsung
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailKeluargaPage(idKeluarga: item['id_keluarga'].toString()),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: badgeColor.withOpacity(0.2),
                    child: Text(item['nama_warga'][0].toUpperCase(),
                        style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['nama_warga'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text("KK : ${item['no_kk']}", style: const TextStyle(color: Colors.black87, fontSize: 12)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
                          child: Text(ekonomi.toUpperCase(),
                              style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  // TOMBOL EDIT & DELETE (Tetep bisa diklik terpisah)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, color: Color(0xFF2D4B1E)),
                        onPressed: () async {
                          final res = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EditKeluargaPage(keluarga: item)),
                          );
                          if (res == true) _getKeluarga();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _deleteKeluarga(item['id_keluarga'].toString()),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // AREA KLIK DETAIL (Dibuat lebih luas pake Padding)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: const Text(
                    "Detail Keluarga >",
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
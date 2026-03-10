import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

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

  Future<void> _getWarga() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.getWarga);
      // Sesuai dengan status 'success' di get.php lu
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2D4B1E),
        title: const Text("Data Warga", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // 1. SEARCH SECTION (Sesuai tema Dashboard)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF2D4B1E),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterWarga,
              decoration: InputDecoration(
                hintText: "Cari nama atau NIK...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),

          // 2. LIST SECTION
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
                : RefreshIndicator(
              onRefresh: _getWarga,
              child: _filteredWarga.isEmpty
                  ? const Center(child: Text("Data warga tidak ditemukan"))
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_warga'),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _buildWargaCard(dynamic warga) {
    // Logika warna badge berdasarkan status kesehatan
    Color statusColor = Colors.blue;
    if (warga['status_kesehatan_khusus'] == 'bumil') statusColor = Colors.pink;
    if (warga['status_kesehatan_khusus'] == 'lansia') statusColor = Colors.orange;
    if (warga['status_kesehatan_khusus'] == 'disabilitas') statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          // Avatar dengan Inisial
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF8CAF5D).withOpacity(0.2),
            child: Text(
              warga['nama'][0].toUpperCase(),
              style: const TextStyle(color: Color(0xFF2D4B1E), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          const SizedBox(width: 15),
          // Info Warga
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(warga['nama'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("NIK: ${warga['nik']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    // Badge Status Kesehatan
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        warga['status_kesehatan_khusus']?.toUpperCase() ?? 'UMUM',
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge BPJS
                    Icon(
                      warga['bpjs_aktif'] == "1" || warga['bpjs_aktif'] == 1
                          ? Icons.verified : Icons.do_not_disturb_on,
                      size: 16,
                      color: warga['bpjs_aktif'] == "1" || warga['bpjs_aktif'] == 1 ? Colors.green : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
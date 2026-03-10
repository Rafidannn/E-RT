import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RiwayatPosyanduPage extends StatefulWidget {
  const RiwayatPosyanduPage({super.key});

  @override
  State<RiwayatPosyanduPage> createState() => _RiwayatPosyanduPageState();
}

class _RiwayatPosyanduPageState extends State<RiwayatPosyanduPage> {
  List<dynamic> _listPosyandu = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  // Ambil data dari get_history.php
  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.getPosyandu);
      if (response['status'] == true) {
        setState(() {
          _listPosyandu = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Posyandu: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Posyandu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background Hijau di atas (Header Dekoratif)
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFF2D4B1E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
              : _listPosyandu.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: _fetchRiwayat,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: _listPosyandu.length,
              itemBuilder: (context, index) {
                return _buildCardPosyandu(_listPosyandu[index]);
              },
            ),
          ),
        ],
      ),

      // Tombol Tambah Data
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Pindah ke halaman input, jika balik membawa data true, refresh list
          final result = await Navigator.pushNamed(context, '/pengumuman');
          if (result == true) {
            _fetchRiwayat();
          }
        },
        backgroundColor: const Color(0xFF8BAE51),
        elevation: 4,
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
    );
  }

  Widget _buildCardPosyandu(dynamic item) {
    bool isBalita = item['kategori'] == 'balita';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Garis warna samping berdasarkan kategori
              Container(
                width: 8,
                color: isBalita ? Colors.blue : Colors.orange,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['nama_warga'] ?? 'Warga',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            item['tanggal'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatItem(Icons.monitor_weight_outlined, "Berat", "${item['berat_badan']} kg"),
                          _buildStatItem(Icons.height_rounded, "Tinggi", "${item['tinggi_badan']} cm"),
                        ],
                      ),
                      const Divider(height: 24),
                      const Text(
                        "Hasil Pemeriksaan:",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['hasil'] ?? '-',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8BAE51)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_information_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Belum ada riwayat pemeriksaan",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
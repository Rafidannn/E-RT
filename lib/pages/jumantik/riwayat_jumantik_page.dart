import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RiwayatJumantikPage extends StatefulWidget {
  const RiwayatJumantikPage({super.key});

  @override
  State<RiwayatJumantikPage> createState() => _RiwayatJumantikPageState();
}

class _RiwayatJumantikPageState extends State<RiwayatJumantikPage> {
  List<dynamic> _listJumantik = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      // Pastiin lu buat endpoint getJumantik di ApiUrl lu nanti
      final response = await ApiService.get(ApiUrl.getJumantik);
      if (response['status'] == true) {
        setState(() {
          _listJumantik = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Jumantik: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Jumantik',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
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
              : _listJumantik.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: _fetchRiwayat,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: _listJumantik.length,
              itemBuilder: (context, index) {
                return _buildCardJumantik(_listJumantik[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Lu bilang pindahnya ke /jumantik, jadi kita ganti rutenya di sini
          final result = await Navigator.pushNamed(context, '/jumantik');

          // Kalau berhasil simpan (kembali bawa data true), refresh listnya
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

  Widget _buildCardJumantik(dynamic item) {
    // Status jentik 'ada' kasih warna merah, 'tidak' kasih warna hijau
    bool adaJentik = item['status_jentik'] == 'ada';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 8,
                color: adaJentik ? Colors.red : Colors.green,
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
                            "Keluarga: ${item['nama_kepala_keluarga'] ?? 'Warga'}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                          Icon(adaJentik ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: adaJentik ? Colors.red : Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            adaJentik ? "Ditemukan Jentik" : "Bebas Jentik",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: adaJentik ? Colors.red : Colors.green
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.person_pin, size: 14, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            "Petugas: ${item['nama_petugas'] ?? '-'}",
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      )
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bug_report_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada laporan jumantik", style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }
}
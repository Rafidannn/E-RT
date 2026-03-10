import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'package:intl/intl.dart';

class RiwayatPengumumanPage extends StatefulWidget {
  const RiwayatPengumumanPage({super.key});

  @override
  State<RiwayatPengumumanPage> createState() => _RiwayatPengumumanPageState();
}

class _RiwayatPengumumanPageState extends State<RiwayatPengumumanPage> {
  List<dynamic> _listRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayat();
  }

  // Fungsi mengambil data dari API
  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.pengumuman);
      if (response['status'] == true) {
        setState(() {
          _listRiwayat = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error Fetch Riwayat: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Riwayat Pengumuman',
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
              : _listRiwayat.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
            onRefresh: _fetchRiwayat,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              itemCount: _listRiwayat.length,
              itemBuilder: (context, index) {
                final item = _listRiwayat[index];
                return _buildCardRiwayat(item);
              },
            ),
          ),
        ],
      ),

      // Floating Action Button di Pojok Kanan Bawah
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman buat pengumuman
          // Jika kembali dari halaman buat pengumuman membawa data true, refresh list
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

  Widget _buildCardRiwayat(dynamic item) {
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
              // Garis hijau di samping kiri card
              Container(width: 6, color: const Color(0xFF8BAE51)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['judul'] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            item['tanggal'] ?? '',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['isi'] ?? '-',
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            "Oleh: ${item['pembuat'] ?? 'Admin'}",
                            style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_late_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Belum ada riwayat pengumuman",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
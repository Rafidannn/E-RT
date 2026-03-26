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

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.getHistoryPosyandu);
      if (response['status'] == true || response['status'] == 'success') {
        setState(() {
          _listPosyandu = (response['data'] ?? []);
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
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28), // Seragam dengan halaman depan Posyandu
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF334A28)))
                      : _listPosyandu.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchRiwayat,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                              itemCount: _listPosyandu.length,
                              itemBuilder: (context, index) {
                                final item = _listPosyandu[index];
                                bool isBalita = item['kategori'] == 'balita';
                                return _buildRiwayatItem(
                                  isBalita ? "B" : "L", 
                                  item['nama_warga'] ?? '-', 
                                  isBalita 
                                    ? "Balita • ${item['berat_badan']} kg • ${item['tinggi_badan']} cm"
                                    : "Lansia • ${item['berat_badan']} kg • ${item['tinggi_badan']} cm • Catatan: ${item['hasil']}",
                                  item['tanggal'] ?? ''
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF759A3D), borderRadius: BorderRadius.circular(15)),
                child: const Text("Riwayat Lengkap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Icon(Icons.history, color: Colors.white, size: 26),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.white54, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildRiwayatItem(String letter, String nama, String detail, String waktu) {
    bool isB = letter == "B";
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
           Container(
             width: 50, height: 50,
             decoration: BoxDecoration(
               color: isB ? const Color(0xFFFDE4F2) : const Color(0xFFE6F2FF),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Center(
               child: Text(
                 letter,
                 style: TextStyle(
                   color: isB ? Colors.pinkAccent : Colors.blueAccent,
                   fontSize: 20, fontWeight: FontWeight.w900
                 ),
               ),
             ),
           ),
           const SizedBox(width: 15),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                 const SizedBox(height: 4),
                 Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.normal), maxLines: 2, overflow: TextOverflow.ellipsis),
               ],
             ),
           ),
           const SizedBox(width: 10),
           Text(
             waktu,
             style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
           ),
        ],
      )
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_weight_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada riwayat pemeriksaan", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

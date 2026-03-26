import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'detail_jumantik_page.dart';

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
      final response = await ApiService.get(ApiUrl.getJumantik);
      if (response['status'] == true || response['status'] == 'success') {
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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28), // Seragam dengan form input Jumantik
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
                      : _listJumantik.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchRiwayat,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                              itemCount: _listJumantik.length,
                              itemBuilder: (context, index) {
                                return _buildCardJumantik(_listJumantik[index]);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/jumantik');
          if (result == true) {
            _fetchRiwayat();
          }
        },
        backgroundColor: const Color(0xFF759A3D),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
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
                child: const Text("Riwayat Jumantik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildCardJumantik(dynamic item) {
    bool adaJentik = item['status_jentik'] == 'ada';
    String namaKeluarga = item['nama_kepala_keluarga'] ?? item['nama_kepala'] ?? item['nama_warga'] ?? 'Keluarga Warga';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailJumantikPage(data: item),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: adaJentik ? Colors.red.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      adaJentik ? Icons.error_outline : Icons.check_circle_outline, 
                      color: adaJentik ? Colors.redAccent : Colors.lightBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        adaJentik ? "ADA JENTIK" : "BEBAS JENTIK",
                        style: TextStyle(fontWeight: FontWeight.w900, color: adaJentik ? Colors.redAccent : Colors.lightBlue, fontSize: 12),
                      ),
                      const SizedBox(height: 2),
                      Text(namaKeluarga, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(item['alamat_lengkap'] ?? 'Alamat tidak diinput', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ],
              ),
              Text(item['tanggal'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Color(0xFFF2F2F2)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_pin, size: 14, color: Colors.grey),
              const SizedBox(width: 5),
              Text("Bertugas: ${item['nama_petugas'] ?? item['petugas'] ?? '-'}", style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: const Text(
               "Detail Riwayat >",
               style: TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)
            )
          )
        ],
      ), // closes Column
    ), // closes Padding
  ), // closes InkWell
); // closes Container
}

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Belum ada laporan jumantik", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}

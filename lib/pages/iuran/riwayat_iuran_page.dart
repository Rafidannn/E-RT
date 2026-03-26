import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RiwayatIuranUserPage extends StatefulWidget {
  final String idKeluarga;
  const RiwayatIuranUserPage({super.key, required this.idKeluarga});

  @override
  State<RiwayatIuranUserPage> createState() => _RiwayatIuranUserPageState();
}

class _RiwayatIuranUserPageState extends State<RiwayatIuranUserPage> {
  List<dynamic> _allData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post(ApiUrl.getIuranByUser, {
        'id_keluarga': 'all',
      });

      if (res['status'] == 'success') {
        setState(() {
          _allData = res['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDetail(dynamic item) {
    showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, size: 40, color: Color(0xFF334A28)),
                  const SizedBox(height: 10),
                  Text(item['nama_kepala'] ?? 'Warga', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 5),
                  Text("No. KK  ${item['no_kk'] ?? '-'}", style: const TextStyle(color: Colors.black54, fontSize: 14)),
                  const SizedBox(height: 10),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: (item['status']?.toString().toLowerCase() == 'lunas') ? const Color(0xFF334A28) : const Color(0xFFE69138),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (item['status']?.toString().toLowerCase() == 'lunas') ? 'Lunas' : 'Belum Lunas',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 15),

                  _buildDetailRow("Jenis Iuran", item['jenis_iuran'] ?? '-'),
                  _buildDetailRow("Periode", "${item['bulan'] ?? '-'} ${item['tahun'] ?? '-'}"),
                  _buildDetailRow("Nominal", "Rp ${(item['nominal'] ?? '0').toString()}"),
                  _buildDetailRow("Tanggal Bayar", item['tanggal_bayar'] ?? '-'),
                  _buildDetailRow("Metode", item['metode_pembayaran'] ?? '-'),

                  if (item['catatan'] != null && item['catatan'].toString().isNotEmpty)
                    _buildDetailRow("Catatan", item['catatan']),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BA54D),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Tutup", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          const Text(" : ", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Dark Green shape
          Positioned(
            top: 0, left: 0, right: 0, bottom: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF334A28),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
          ),
          // Logo ERT
          Positioned(
            top: 300,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset('assets/images/logo_ert.png', width: 250, fit: BoxFit.contain),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildTabs(),
                const SizedBox(height: 30),

                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _allData.isEmpty
                      ? const Center(child: Text("Belum ada riwayat iuran", style: TextStyle(color: Colors.white)))
                      : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      itemCount: _allData.length,
                      itemBuilder: (context, index) {
                        final item = _allData[index];
                        return GestureDetector(
                          onTap: () => _showDetail(item),
                          child: Container(
                            height: 80,
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(item['nama_kepala'] ?? "Warga", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text("${item['bulan']} ${item['tahun']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("Rp ${item['nominal'] ?? '0'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF334A28))),
                                    Text(
                                        (item['status']?.toString().toLowerCase() == 'lunas') ? 'Lunas' : 'Belum Lunas',
                                        style: TextStyle(
                                            color: (item['status']?.toString().toLowerCase() == 'lunas') ? Colors.green : Colors.orange,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold
                                        )
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF8BA54D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text("Riwayat Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          // Icon dihapus sesuai permintaan
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/verifikasi_pembayaran');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE69138),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.chevron_left, color: Colors.white, size: 16),
                SizedBox(width: 5),
                Text("Verifikasi Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE69138),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Text("Riwayat Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(width: 5),
              Icon(Icons.chevron_right, color: Colors.white, size: 16),
            ],
          ),
        )
      ],
    );
  }
}

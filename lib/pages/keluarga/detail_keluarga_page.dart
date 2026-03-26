import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class DetailKeluargaPage extends StatefulWidget {
  final String idKeluarga;
  const DetailKeluargaPage({super.key, required this.idKeluarga});

  @override
  State<DetailKeluargaPage> createState() => _DetailKeluargaPageState();
}

class _DetailKeluargaPageState extends State<DetailKeluargaPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await ApiService.get("${ApiUrl.getDetailKeluarga}?id_keluarga=${widget.idKeluarga}");
      if (response['status'] == true) {
        setState(() => _data = response['data']);
      }
    } catch (e) {
      debugPrint("Error Fetch Detail: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var info = _data?['info'];
    var listAnggota = _data?['anggota'] as List?;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Putih sebagai layar dasar keseluruhan
      body: Stack(
        children: [
          // Background Color CUMA SETENGAH
          Positioned(
            top: 0, left: 0, right: 0, bottom: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF2D4B1E), // Dark Green top
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF), // Cream card
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Stack(
                              children: [
                                // Watermark ERT Logo di dalam Card
                                Positioned.fill(
                                  top: 150,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Opacity(
                                      opacity: 0.25,
                                      child: Image.asset('assets/images/logo_ert.png', width: 220, fit: BoxFit.contain),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(25),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Detail Keluarga",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54),
                                      ),
                                      const SizedBox(height: 10),
                                      const Divider(thickness: 1.5, color: Colors.grey),
                                      const SizedBox(height: 20),

                                      // Orange Avatar
                                      Center(
                                        child: CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.orange,
                                          child: const Icon(Icons.person_outline, size: 45, color: Colors.white),
                                        ),
                                      ),
                                      const SizedBox(height: 15),

                                      Text(
                                        "No. KK : ${info?['no_kk'] ?? '-'}",
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                      const SizedBox(height: 30),

                                      // Anggota Keluarga Box
                                      _buildBoxInfo(
                                        title: "Anggota Keluarga :",
                                        content: listAnggota != null && listAnggota.isNotEmpty
                                            ? listAnggota.map((w) => "• ${w['nama']} (${w['nik']})").join("\n")
                                            : "-",
                                        minLines: 5,
                                      ),
                                      const SizedBox(height: 15),

                                      _buildBoxInfo(
                                        title: "Sumber Air :",
                                        content: info?['sumber_air'] ?? "-",
                                      ),
                                      const SizedBox(height: 15),

                                      _buildBoxInfo(
                                        title: "Pengelolaan Sampah :",
                                        content: info?['pengelolaan_sampah'] ?? "-",
                                      ),
                                      const SizedBox(height: 15),

                                      _buildBoxInfo(
                                        title: "Kepemilikan Jamban & Toga :",
                                        content: "Jamban: ${info?['memiliki_jamban'] == '1' ? 'Ada' : 'Tidak'}\n"
                                                 "Toga: ${info?['memiliki_toga'] == '1' ? 'Ada' : 'Tidak'}",
                                      ),

                                      const SizedBox(height: 50),
                                    ],
                                  ),
                                ),
                              ],
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
             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
             decoration: BoxDecoration(
                color: const Color(0xFF8CAF5D),
                borderRadius: BorderRadius.circular(20),
             ),
             child: const Text("Data Keluarga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxInfo({required String title, required String content, int minLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
          minLines > 1 ? const SizedBox(height: 10) : const SizedBox(height: 3),
          Text(content, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          if (minLines > 1 && content.length < 50) SizedBox(height: minLines * 12.0),
        ],
      ),
    );
  }
}

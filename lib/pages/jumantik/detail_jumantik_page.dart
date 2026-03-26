import 'package:flutter/material.dart';
import '../../core/constants/api_url.dart';

class DetailJumantikPage extends StatelessWidget {
  final dynamic data;
  const DetailJumantikPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    bool adaJentik = data['status_jentik'] == 'ada';
    String namaKeluarga = data['nama_kepala_keluarga'] ?? data['nama_kepala'] ?? data['nama_warga'] ?? 'Keluarga Warga';
    String? foto = data['foto'];

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Latar Hijau Atas
          Positioned(
            top: 0, left: 0, right: 0, bottom: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF334A28),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF), // Cream card
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
                        ]
                      ),
                      child: Stack(
                        children: [
                           // Watermark Logo ERT
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Laporan Pemeriksaan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                                const SizedBox(height: 10),
                                const Divider(thickness: 1.5, color: Colors.grey),
                                const SizedBox(height: 20),

                                // Ikon Status Jentik (Avatar)
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: adaJentik ? Colors.red.shade100 : Colors.blue.shade100,
                                  child: Icon(
                                    adaJentik ? Icons.error_outline : Icons.check_circle_outline, 
                                    size: 45, 
                                    color: adaJentik ? Colors.red : Colors.lightBlue
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Text(adaJentik ? "ADA JENTIK" : "BEBAS JENTIK", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: adaJentik ? Colors.red : Colors.lightBlue)),
                                const SizedBox(height: 30),

                                // Kumpulan Detail Kotak Putih
                                _buildDetailBox("Keluarga Tercatat", "$namaKeluarga\nKK : ${data['no_kk'] ?? '-'}"),
                                const SizedBox(height: 15),
                                _buildDetailBox("Alamat / Lokasi", data['alamat_lengkap'] ?? '-'),
                                const SizedBox(height: 15),
                                _buildDetailBox("Sumber Air Diperiksa", data['wadah'] ?? '-'),
                                const SizedBox(height: 15),
                                _buildDetailBox("Tanggal Pengecekan", data['tanggal'] ?? '-'),
                                const SizedBox(height: 15),
                                _buildDetailBox("Catatan Petugas", (data['catatan'] != null && data['catatan'].toString().trim().isNotEmpty) ? data['catatan'] : 'Tidak ada catatan tambahan', minLines: 2),
                                const SizedBox(height: 15),
                                _buildDetailBox("Nama Petugas", data['nama_petugas'] ?? '-'),
                                const SizedBox(height: 25),

                                // FOTO BUKTI
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Foto Bukti Laporan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: (foto == null || foto.isEmpty)
                                      ? const Center(child: Text("Tidak ada foto yang dilampirkan", style: TextStyle(color: Colors.grey, fontSize: 12)))
                                      : GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  backgroundColor: Colors.black,
                                                  appBar: AppBar(
                                                    backgroundColor: Colors.black,
                                                    iconTheme: const IconThemeData(color: Colors.white),
                                                    title: const Text("Foto Detail", style: TextStyle(color: Colors.white)),
                                                  ),
                                                  body: Center(
                                                    child: InteractiveViewer(
                                                      panEnabled: true,
                                                      minScale: 0.5,
                                                      maxScale: 4,
                                                      child: Image.network(
                                                        "${ApiUrl.baseUrl}/$foto",
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context, error, stackTrace) => const Center(child: Text("Gagal memuat foto", style: TextStyle(color: Colors.red))),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image.network(
                                            "${ApiUrl.baseUrl}/$foto",
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => const Center(child: Text("Gagal memuat foto", style: TextStyle(color: Colors.red))),
                                          ),
                                        ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ]
                      )
                    )
                  )
                )
              ],
            )
          )
        ]
      )
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
                color: const Color(0xFF8BA54D),
                borderRadius: BorderRadius.circular(20),
             ),
             child: const Text("Detail Jumantik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailBox(String title, String content, {int minLines = 1}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 5),
          Text(content, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold, height: 1.3)),
          if (minLines > 1) SizedBox(height: (minLines - 1) * 15.0)
        ],
      ),
    );
  }
}

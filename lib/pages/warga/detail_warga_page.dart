import 'package:flutter/material.dart';

class DetailWargaPage extends StatelessWidget {
  final Map<String, dynamic> warga;
  const DetailWargaPage({super.key, required this.warga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Dasar layar bawah putih
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER HIJAU ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 40, bottom: 80),
              decoration: const BoxDecoration(
                color: Color(0xFF2D4B1E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CAF5D),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Data Warga",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- CARD KREM (DIBUAT KECIL/MENYESUAIKAN ISI) ---
            Transform.translate(
              offset: const Offset(0, -50), // Menaikkan card agar overlap ke area hijau
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F2), // Warna Krem
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // KUNCI: Biar card tidak memanjang ke bawah
                    children: [
                      const Text(
                        "Detail Warga",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(thickness: 1.5, color: Colors.grey),
                      ),

                      // Avatar
                      Center(
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.person, size: 55, color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // List Data Box Putih
                      _buildDetailBox("Nama Lengkap", warga['nama']),
                      _buildDetailBox("Nik", warga['nik']),
                      _buildDetailBox("Jenis Kelamin", warga['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan'),
                      _buildDetailBox("Tempat, Tanggal Lahir", "${warga['tempat_lahir']}, ${warga['tanggal_lahir']}"),
                      _buildDetailBox("Pendidikan Terakhir", warga['pendidikan']),
                      _buildDetailBox("Pekerjaan", warga['pekerjaan']),
                      _buildDetailBox("Status Perkawinan", warga['status_perkawinan']),
                      _buildDetailBox("No. KK", warga['no_kk'] ?? "-"),
                      _buildDetailBox("Status Kesehatan Khusus", warga['status_kesehatan_khusus']),
                      _buildDetailBox("Status BPJS", warga['bpjs_aktif'] == "1" || warga['bpjs_aktif'] == 1 ? "Aktif" : "Tidak Aktif"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Memberi sedikit jarak di paling bawah
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBox(String label, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? "-",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
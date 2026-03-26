import 'package:flutter/material.dart';

class VerifikasiPembayaranPage extends StatefulWidget {
  const VerifikasiPembayaranPage({super.key});

  @override
  State<VerifikasiPembayaranPage> createState() => _VerifikasiPembayaranPageState();
}

class _VerifikasiPembayaranPageState extends State<VerifikasiPembayaranPage> {
  int _activeTab = 0; // 0 for Menunggu, 1 for Selesai

  // Dummy data sesuai dengan gambar mockup
  final List<Map<String, dynamic>> _listMenunggu = [
    {
      "nama": "Bapak Hendra Gunawan",
      "kk": "3171XXXXXXXXXX",
      "rt_rw": "RT 05 / RW 02",
      "jenis": "IURAN KEAMANAN",
      "periode": "Maret 2026",
      "nominal": "50.000",
      "image_color": const Color(0xFFD69888), // Warna placeholder receipt 1
    },
    {
      "nama": "Ibu Siti Aminah",
      "kk": "3171XXXXXXXXXX",
      "rt_rw": "RT 05 / RW 02",
      "jenis": "IURAN SAMPAH",
      "periode": "Maret 2026",
      "nominal": "30.000",
      "image_color": const Color(0xFFC7986B), // Warna placeholder receipt 2
    },
    {
      "nama": "Bapak Agus Susanto",
      "kk": "3171XXXXXXXXXX",
      "rt_rw": "RT 05 / RW 02",
      "jenis": "IURAN KEAMANAN",
      "periode": "Februari 2026",
      "nominal": "50.000",
      "image_color": const Color(0xFF869CA9), // Warna placeholder receipt 3
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        title: const Text(
          "Verifikasi Pembayaran",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Berdasarkan gambar judul di tengah sedikit bergeser
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Verifikasi Iuran Masuk",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Terdapat ${_listMenunggu.length} laporan pembayaran menunggu validasi.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Tabs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _activeTab == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Menunggu",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            if (_activeTab == 0) ...[
                              const SizedBox(width: 5),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.black87,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _activeTab == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            "Selesai",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 1 ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // List Section
          Expanded(
            child: _activeTab == 0
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _listMenunggu.length,
                    itemBuilder: (context, index) {
                      final item = _listMenunggu[index];
                      return _buildCardItem(item);
                    },
                  )
                : const Center(
                    child: Text(
                      "Tidak ada data selesai.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF334A28),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 1, // Set to Verifikasi
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light green background
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.verified_user_outlined, color: Color(0xFF334A28)),
            ),
            label: "Verifikasi",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Laporan",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profil",
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Identity Section
          Text(
            item["nama"],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            "KK : ${item["kk"]}",
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            item["rt_rw"],
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Payment Info
          Text(
            item["jenis"],
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A6836), // Greenish text
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item["periode"],
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 5),
          Text(
            "Rp ${item["nominal"]}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),

          // Receipt Image Placeholder (Mock)
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: item["image_color"],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.receipt_long_outlined, size: 60, color: Colors.white.withValues(alpha: 0.5)),
                   const SizedBox(height: 10),
                   Text(
                     "Bukti Transfer",
                     style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.bold),
                   )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              // Tolak Button
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red.shade100, width: 1),
                    borderRadius: BorderRadius.circular(8), // Or match design
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Handle tolak
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Iuran ditolak untuk ${item['nama']}")),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, color: Colors.red.shade700, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "TOLAK",
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10), // Gap
              // Terima Button
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2C18), // Dark dark green like image
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    onTap: () {
                      // TODO: Handle terima
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Iuran diterima untuk ${item['nama']}!")),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text(
                          "TERIMA",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

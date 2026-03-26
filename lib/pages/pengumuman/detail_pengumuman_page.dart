import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:intl/intl.dart';

class DetailPengumumanPage extends StatelessWidget {
  final Map<String, dynamic> pengumumanData;
  const DetailPengumumanPage({super.key, required this.pengumumanData});

  void _bagikanKeWhatsApp() {
    final String judul = pengumumanData['judul'] ?? "Pengumuman";
    final String tanggal = pengumumanData['tanggal'] ?? "-";
    final String waktu = pengumumanData['waktu'] ?? "-";
    final String lokasi = pengumumanData['lokasi'] ?? "Belum ditentukan";
    final String isi = pengumumanData['isi'] ?? "Detail tidak tersedia.";
    
    final String pesan = "📢 *PENGUMUMAN RT*\n\n"
        "*$judul*\n\n"
        "🗓️ *Tanggal*: $tanggal\n"
        "🕒 *Waktu*: $waktu\n"
        "📍 *Lokasi*: $lokasi\n\n"
        "📝 *Keterangan*:\n$isi\n\n"
        "_Pesan ini dikirim secara otomatis melalui Aplikasi ERT. Mari berpartisipasi dan sampaikan ide terbaik demi lingkungan tercinta!_";
        
    Share.share(pesan);
  }

  void _simpanKeKalender(BuildContext context) {
    try {
      DateTime startDate = DateTime.now();
      if (pengumumanData['tanggal'] != null) {
        // Coba terjemahkan format yyyy-MM-dd
        startDate = DateTime.parse(pengumumanData['tanggal']);
      }
      
      final Event event = Event(
        title: pengumumanData['judul'] ?? "Pengumuman RT",
        description: pengumumanData['isi'] ?? "Kegiatan RT",
        location: pengumumanData['lokasi'] ?? "Lingkungan RT",
        startDate: startDate,
        endDate: startDate.add(const Duration(hours: 2)),
      );
      
      Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint("Error Add2Calendar: $e");
    }
  }

  void _onSearchPressed(BuildContext context) {
    // Karena delegate search ada di halaman daftar, kita arahkan user kembali
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("Ketuk ikon Search di halaman daftar untuk mencari pengumuman."))
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7FCF6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengumuman RT",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () => _onSearchPressed(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header Placeholder
            Container(
               height: 220,
               width: double.infinity,
               decoration: BoxDecoration(
                 color: pengumumanData['image'] is Color ? pengumumanData['image'] : const Color(0xFFE8D0B3),
                 image: pengumumanData['image'] is String ? DecorationImage(image: NetworkImage(pengumumanData['image']), fit: BoxFit.cover) : null,
               ),
               child: Stack(
                 children: [
                    if (pengumumanData['kategori'] != null && pengumumanData['kategori'] != "TERBARU")
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF14301C), 
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            pengumumanData['kategori'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                 ],
               ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    pengumumanData['judul'] ?? "Pengumuman",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3),
                  ),
                  const SizedBox(height: 15),
                  
                  // Meta Info
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(pengumumanData['tanggal'] ?? "-", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                      const SizedBox(width: 15),
                      const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                      const SizedBox(width: 5),
                      Text(pengumumanData['pembuat'] ?? "Admin RT", style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // Body Text
                  Text(
                    pengumumanData['isi'] ?? "Detail pengumuman belum tersedia.",
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Detail Kegiatan Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EFE5), // Soft grey-green box
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             const Icon(Icons.info_outline, size: 18, color: Colors.black87),
                             const SizedBox(width: 10),
                             const Text("Detail Kegiatan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                           ],
                         ),
                         const SizedBox(height: 20),
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Icon(Icons.location_on_outlined, size: 18, color: Colors.black87),
                             const SizedBox(width: 10),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                   const SizedBox(height: 2),
                                   Text(pengumumanData['lokasi'] ?? "Belum ditentukan", style: const TextStyle(fontSize: 13)),
                                 ],
                               )
                             )
                           ],
                         ),
                         const SizedBox(height: 20),
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const Icon(Icons.access_time_outlined, size: 18, color: Colors.black87),
                             const SizedBox(width: 10),
                             Expanded(
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   const Text("Waktu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                   const SizedBox(height: 2),
                                   Text("${pengumumanData['waktu'] ?? '-'} - Selesai", style: const TextStyle(fontSize: 13)),
                                 ],
                               )
                             )
                           ],
                         ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Text motivation
                  const Text(
                    "Kehadiran Bapak/Ibu sangat diharapkan demi tercapainya mufakat dan keamanan lingkungan yang lebih baik untuk kita semua. Mari kita sampaikan ide dan masukan terbaik untuk lingkungan tercinta.",
                    style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.6),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F2C18), // Dark green
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _bagikanKeWhatsApp,
                      icon: const Icon(Icons.share, color: Colors.white, size: 18),
                      label: const Text("Bagikan ke WhatsApp", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black87, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.transparent, // Outline button
                      ),
                      onPressed: () => _simpanKeKalender(context),
                      icon: const Icon(Icons.calendar_today_outlined, color: Colors.black87, size: 18),
                      label: const Text("Simpan ke Kalender", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavbar(context),
    );
  }

  Widget _buildBottomNavbar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             // Menggunakan dashboard_admin sesuai instruksi terbaru
             _buildBottomNavItem(context, Icons.home_outlined, "BERANDA", false, '/dashboard_admin'),
             _buildBottomNavItem(context, Icons.calendar_month_outlined, "KEGIATAN", true, null),
             _buildBottomNavItem(context, Icons.people_outline, "WARGA", false, '/manage_warga'),
             _buildBottomNavItem(context, Icons.person_outline, "PROFIL", false, null),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(BuildContext context, IconData icon, String label, bool isActive, String? routeName) {
    Widget itemWidget;
    
    if (isActive) {
      itemWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF14301C), // Dark green background
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    } else {
      itemWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () {
         if (routeName != null) {
            if (label == "BERANDA") {
              Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => false);
            } else {
              Navigator.pushNamed(context, routeName);
            }
         } else if (!isActive) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Halaman $label sedang dalam konstruksi')));
         }
      },
      borderRadius: BorderRadius.circular(30),
      child: itemWidget,
    );
  }
}

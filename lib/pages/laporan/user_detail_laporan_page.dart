import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_url.dart';

class UserDetailLaporanPage extends StatelessWidget {
  final Map<String, dynamic> laporanData;

  const UserDetailLaporanPage({super.key, required this.laporanData});

  @override
  Widget build(BuildContext context) {
    String subjek = laporanData['subjek'] ?? '';
    String kategori = laporanData['kategori'] ?? '';
    String detail = laporanData['detail'] ?? '';
    String lokasi = laporanData['lokasi'] ?? '';
    String status = laporanData['status'] ?? 'TERKIRIM';
    String tglStr = laporanData['tanggal_laporan'] ?? '';

    String displayDate = tglStr;
    try {
       DateTime dt = DateTime.parse(tglStr);
       displayDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt) + ' WIB';
    } catch(e) {}

    Color iconBg = const Color(0xFFEEF5FD);
    Color iconColor = const Color(0xFF4A90E2);
    IconData statusIcon = Icons.send;
    String statusDesc = "Laporan berhasil terkirim ke sistem.";

    if (status == 'DIPROSES') { 
      iconBg = const Color(0xFFFFF4E5); iconColor = const Color(0xFFF39C12); 
      statusIcon = Icons.settings_applications; 
      statusDesc = "Laporan sedang diproses oleh petugas RT.";
    }
    else if (status == 'SELESAI') { 
      iconBg = const Color(0xFFE8F5E9); iconColor = const Color(0xFF2ECC71); 
      statusIcon = Icons.check_circle; 
      statusDesc = "Laporan telah diselesaikan.";
    }
    else if (status == 'DITOLAK') { 
      iconBg = const Color(0xFFFFEBEE); iconColor = Colors.red; 
      statusIcon = Icons.cancel; 
      statusDesc = "Laporan ditolak atau dibatalkan.";
    }

    String photoUrl = "";
    if (laporanData['foto_bukti'] != null && laporanData['foto_bukti'].toString().isNotEmpty && laporanData['foto_bukti'].toString() != "Tidak ada foto") {
       String imageName = laporanData['foto_bukti'].toString();
       if (imageName.startsWith('uploads/')) {
           photoUrl = "${ApiUrl.baseUrl}/$imageName".trim();
       } else if (imageName.startsWith('http')) {
           photoUrl = imageName;
       } else {
           photoUrl = "${ApiUrl.baseUrl}/uploads/$imageName".trim();
       }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EF),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 400,
              decoration: const BoxDecoration(
                color: Color(0xFF0C2B14),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(55)),
              ),
            )
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Status Icon
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: iconBg,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: iconBg.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 5))]
                          ),
                          child: Icon(statusIcon, color: iconColor, size: 45),
                        ),
                        const SizedBox(height: 15),
                        const Text("STATUS LAPORAN", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                        const SizedBox(height: 5),
                        Text(status, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(displayDate, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        
                        const SizedBox(height: 40),
                        
                        // Kartu Detail
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(20),
                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 10))]
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                child: Text(kategori.toUpperCase(), style: const TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 15),
                              Text(subjek, style: const TextStyle(color: const Color(0xFF1E272E), fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                              const SizedBox(height: 25),
                              
                              const Text("DETAIL LAPORAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Text(detail, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5)),
                              
                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                              
                              const Text("LOKASI KEJADIAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on, color: Color(0xFF7CB342), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(lokasi.isNotEmpty ? lokasi : '-', style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600))),
                                ],
                              ),
                              
                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                              
                              const Text("LAMPIRAN FOTO", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 15),
                              if (photoUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    photoUrl,
                                    width: double.infinity,
                                    height: 250, // Added explicit height to prevent 0-dimensions
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height: 250, width: double.infinity,
                                        alignment: Alignment.center,
                                        child: CircularProgressIndicator(color: const Color(0xFF7CB342), strokeWidth: 3),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 150, width: double.infinity,
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(15)),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                          SizedBox(height: 10),
                                          Text("Foto tidak dapat dimuat", style: TextStyle(color: Colors.grey, fontSize: 12))
                                        ]
                                      )
                                    ),
                                  )
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 30),
                                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade200)),
                                  child: Column(
                                    children: const [
                                      Icon(Icons.image_not_supported_outlined, color: Colors.black26, size: 40),
                                      SizedBox(height: 10),
                                      Text("Tidak ada foto dilampirkan", style: TextStyle(color: Colors.grey, fontSize: 12))
                                    ]
                                  )
                                ),
                                
                              const SizedBox(height: 25),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(color: iconBg.withOpacity(0.4), borderRadius: BorderRadius.circular(12), border: Border.all(color: iconColor.withOpacity(0.3))),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: iconColor, size: 20),
                                    const SizedBox(width: 15),
                                    Expanded(child: Text(statusDesc, style: TextStyle(color: iconColor.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.bold, height: 1.4))),
                                  ]
                                )
                              )
                            ],
                          )
                        ),
                        const SizedBox(height: 40),
                      ]
                    )
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Container(
             decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
             child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
             decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(20)),
             child: const Text("Detail Laporan", style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
           ),
           const SizedBox(width: 40), // Placeholder to center the middle widget
        ],
      )
    );
  }
}

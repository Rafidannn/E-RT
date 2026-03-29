import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/api_url.dart';

class UserDetailSuratPage extends StatelessWidget {
  final Map<String, dynamic> suratData;

  const UserDetailSuratPage({super.key, required this.suratData});

  @override
  Widget build(BuildContext context) {
    String jenis = suratData['jenis_surat'] ?? '';
    String tglStr = suratData['tanggal_pengajuan'] ?? '';
    String status = suratData['status'] ?? 'MENUNGGU';
    String catatan = suratData['catatan_admin'] ?? '';
    String keperluan = suratData['keperluan'] ?? '-';
    String metode = suratData['metode_pengambilan'] ?? 'Fisik';
    
    String displayDate = tglStr;
    try {
       DateTime dt = DateTime.parse(tglStr);
       displayDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt) + ' WIB';
    } catch(e) {}

    Color iconBg = const Color(0xFFFFF8E1);
    Color iconColor = const Color(0xFFF57F17);
    IconData statusIcon = Icons.hourglass_top;
    String statusDesc = "Pengajuan menunggu persetujuan Ketua RT.";

    if (status == 'DISETUJUI') { 
      iconBg = const Color(0xFFE8F8F5); iconColor = const Color(0xFF27AE60); 
      statusIcon = Icons.check_circle_outline; 
      statusDesc = "Surat telah disetujui. Silakan ikuti metode pengambilan yang Anda pilih.";
    }
    else if (status == 'DITOLAK') { 
      iconBg = const Color(0xFFFDEDEC); iconColor = const Color(0xFFC0392B); 
      statusIcon = Icons.cancel_outlined; 
      statusDesc = "Pengajuan ditolak. Periksa catatan penolakan.";
    }

    String photoUrl = "";
    if (suratData['file_lampiran'] != null && suratData['file_lampiran'].toString().isNotEmpty) {
       final raw = suratData['file_lampiran'].toString();
       if (raw.startsWith('http')) {
         photoUrl = raw;
       } else if (raw.startsWith('uploads/')) {
         // format lama: "uploads/filename.jpg" → paksa ke root uploads
         photoUrl = "${ApiUrl.baseUrl}/${raw}".trim();
       } else {
         // format baru: hanya "filename.jpg"
         photoUrl = "${ApiUrl.baseUrl}/uploads/$raw".trim();
       }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EF), // Sama kayak user_laporan_page BG
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 350,
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
                        const Text("STATUS PENGAJUAN", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
                                decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
                                child: const Text("PENGAJUAN SURAT PENGANTAR", style: TextStyle(color: Color(0xFF1565C0), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              ),
                              const SizedBox(height: 15),
                              Text(jenis, style: const TextStyle(color: Color(0xFF1E272E), fontSize: 18, fontWeight: FontWeight.w900, height: 1.3)),
                              const SizedBox(height: 25),
                              
                              const Text("KEPERLUAN", style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 8),
                              Text(keperluan, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
                              
                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                              
                              const Text("METODE PENGAMBILAN", style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(metode == 'Fisik' ? Icons.local_printshop_outlined : Icons.picture_as_pdf_outlined, color: const Color(0xFF7CB342), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(metode == 'Fisik' ? 'Ambil Fisik di Ketua RT' : 'Kirim File Digital (PDF)', style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600))),
                                ],
                              ),
                              
                              if (status == 'DISETUJUI' && metode == 'Digital') ... [
                                 const SizedBox(height: 15),
                                 SizedBox(
                                   width: double.infinity,
                                   child: ElevatedButton.icon(
                                     onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mulai mengunduh dokumen PDF surat...")));
                                     },
                                     icon: const Icon(Icons.download, color: Colors.white, size: 18),
                                     label: const Text("Unduh Surat (PDF)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                     style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF27AE60), 
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                     ),
                                   )
                                 )
                              ],

                              if (status == 'DITOLAK' && catatan.isNotEmpty) ... [
                                 const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                                 const Text("CATATAN PENOLAKAN", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                 const SizedBox(height: 8),
                                 Container(
                                     width: double.infinity,
                                     padding: const EdgeInsets.all(12),
                                     decoration: BoxDecoration(color: const Color(0xFFFDEDEC), borderRadius: BorderRadius.circular(10)),
                                     child: Text(catatan, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 12, height: 1.5, fontStyle: FontStyle.italic)),
                                 ),
                              ],

                              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                              
                              const Text("LAMPIRAN FOTO DOKUMEN", style: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                              const SizedBox(height: 15),
                              if (photoUrl.isNotEmpty) // Gambar Network
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
                                        child: const CircularProgressIndicator(color: Color(0xFF7CB342), strokeWidth: 3),
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
                                      Text("Tidak ada dokumen yang diunggah", style: TextStyle(color: Colors.grey, fontSize: 12))
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
             child: const Text("Detail Pengajuan", style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
           ),
           const SizedBox(width: 40), 
        ],
      )
    );
  }
}

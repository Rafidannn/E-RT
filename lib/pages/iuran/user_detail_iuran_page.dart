import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_url.dart';

class UserDetailPage extends StatefulWidget {
  final Map<String, dynamic> iuranData;

  const UserDetailPage({super.key, required this.iuranData});

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  String _noKk = "Memuat...";
  String _namaKepala = "-";

  @override
  void initState() {
    super.initState();
    _namaKepala = widget.iuranData['nama_kepala'] ?? '-';
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nik = prefs.getString('nik_user') ?? '';
    if (nik.isEmpty) return;
    
    try {
      final res = await http.get(Uri.parse("${ApiUrl.getProfilByNik}?nik=$nik"));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          if (mounted) {
            setState(() {
              _namaKepala = data['data']['nama_kepala'] ?? data['data']['nama'];
              _noKk = data['data']['no_kk'] ?? '-';
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Err profil: $e");
    }
  }

  String _formatCurrency(dynamic amount) {
    int val = int.tryParse(amount.toString()) ?? 0;
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(val);
  }

  @override
  Widget build(BuildContext context) {
    String statusRaw = widget.iuranData['status']?.toString().toLowerCase() ?? '';
    String titleStatus = "Menunggu Verifikasi";
    Color iconBg = Colors.orange;
    IconData iconStatus = Icons.access_time_filled;
    
    if (statusRaw == 'lunas') {
      titleStatus = "Pembayaran Berhasil";
      iconBg = const Color(0xFFE99625); // kuning-oren emas ala desain
      iconStatus = Icons.check_circle;
    } else if (statusRaw == 'ditolak') {
      titleStatus = "Pembayaran Ditolak";
      iconBg = Colors.red;
      iconStatus = Icons.cancel;
    }

    String trxId = widget.iuranData['transaction_id'] ?? "-";
    if (trxId.isEmpty || trxId == "null") trxId = "-";

    String tgl = widget.iuranData['tanggal_bayar'] ?? '';
    String formattedDate = "-";
    if (tgl.isNotEmpty && tgl != "null") {
      try {
        DateTime parsed = DateTime.parse(tgl);
        formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsed) + ' WIB';
      } catch (e) {
        formattedDate = tgl;
      }
    }

    // Bangun base url images
    String photoUrl = "";
    String localPath = widget.iuranData['bukti_transfer_local'] ?? "";
    if (widget.iuranData['bukti_transfer'] != null && widget.iuranData['bukti_transfer'].toString().isNotEmpty) {
       photoUrl = "${ApiUrl.baseUrl}/iuran/${widget.iuranData['bukti_transfer']}";
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EF),
      body: Stack(
        children: [
          // Dark green top background stretched heavily down
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 480, // Ditarik jauh ke bawah
              decoration: const BoxDecoration(
                color: Color(0xFF0C2B14),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(55), bottomRight: Radius.circular(55)),
              ),
            )
          ),
          
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  
                  // Status Icon (Bulak balik tengah)
                  Container(
                    width: 75, height: 75,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: iconBg.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8))]
                    ),
                    child: Icon(iconStatus, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 18),
                  
                  const Text("STATUS TRANSAKSI", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                  const SizedBox(height: 5),
                  Text(titleStatus, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(_formatCurrency(widget.iuranData['nominal']), style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                  
                  const SizedBox(height: 40),
                  
                  // Kotak Detail Utama (Tengah Ngangkang)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 25, offset: const Offset(0, 10))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("JENIS IURAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        Text(widget.iuranData['jenis_iuran'] ?? '-', style: const TextStyle(color: Color(0xFF1E272E), fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 25),
                        
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("PERIODE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  const SizedBox(height: 5),
                                  Text("${widget.iuranData['bulan']} ${widget.iuranData['tahun']}", style: const TextStyle(color: Color(0xFF1E272E), fontSize: 15, fontWeight: FontWeight.bold)),
                                ]
                              )
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("TANGGAL", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                  const SizedBox(height: 5),
                                  Text(formattedDate, style: const TextStyle(color: Color(0xFF1E272E), fontSize: 13, fontWeight: FontWeight.bold, height: 1.4)),
                                ]
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        
                        const Text("TRANSACTION ID", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(5)),
                          child: Text(trxId, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontFamily: 'Courier', letterSpacing: 0.5)),
                        ),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Colors.black12, thickness: 1)),
                        
                        const Text("DETAIL PEMBAYAR", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 15),
                        _buildDetailRow("Kepala Keluarga", "Bpk. $_namaKepala"),
                        const SizedBox(height: 15),
                        _buildDetailRow("Nomor KK", _noKk),
                        const SizedBox(height: 15),
                        _buildDetailRow("Metode", widget.iuranData['metode_pembayaran'] ?? '-'),
                        
                        const SizedBox(height: 25),
                        const Text("BUKTI TRANSFER", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        const SizedBox(height: 10),
                        
                        if (localPath.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(localPath),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          )
                        else if (photoUrl.isNotEmpty) // Menampilkan gambar network jika ada
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              photoUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 100, width: 100, 
                                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.broken_image, color: Colors.grey)
                              ),
                            )
                          )
                        else
                          const Text("Pembayaran Tunai (Tidak ada bukti)", style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          
                        const SizedBox(height: 30),
                        
                        // Garis putus-putus manual ala Text
                        Text(" - "*28, maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(color: Colors.grey.shade300, fontSize: 12)),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle),
                              child: const Icon(Icons.shield_outlined, color: Colors.green, size: 20),
                            ),
                            const SizedBox(width: 15),
                            const Expanded(
                              child: Text("Diterima oleh Bendahara RT 05\nSistem Digital Terverifikasi", style: TextStyle(fontSize: 11, color: Colors.black87, height: 1.4, fontWeight: FontWeight.w500)),
                            )
                          ],
                        )
                      ],
                    )
                  ),
                  
                  const SizedBox(height: 40),
                ]
              )
            )
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        color: const Color(0xFFF9F7EF),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unduh Resi PDF diproses...")));
                },
                icon: const Icon(Icons.download, color: Colors.white, size: 20),
                label: const Text("UNDUH RESI (PDF/JPG)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C2B14),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur bagikan disimulasikan!")));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.share, color: Color(0xFF0C2B14), size: 18),
                  SizedBox(width: 8),
                  Text("BAGIKAN", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0C2B14), letterSpacing: 1)),
                ],
              )
            )
          ]
        )
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(width: 20),
        Expanded(
          child: Text(val, textAlign: TextAlign.right, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1.5)),
                child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context, true), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(20)),
                child: const Text("Detail Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 26), onPressed: (){}),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white30, thickness: 1),
        ],
      )
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/constants/api_url.dart';
import 'user_riwayat_iuran_page.dart';
import 'user_detail_iuran_page.dart';

class UserBayarIuranPage extends StatefulWidget {
  const UserBayarIuranPage({super.key});

  @override
  State<UserBayarIuranPage> createState() => _UserBayarIuranPageState();
}

class _UserBayarIuranPageState extends State<UserBayarIuranPage> {
  String _namaKepala = "Memuat...";
  String _noKk = "Memuat...";
  String _idKeluarga = "";
  String _idUser = "";
  
  String _jenisIuran = "Iuran Kas RT";
  final List<String> _listJenis = ["Iuran Kas RT", "Iuran Sampah/Kebersihan", "Iuran Keamanan", "Iuran Kematian", "Iuran Sosial"];
  
  String _periodeBulan = "Januari";
  final List<String> _listBulan = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
  
  int _nominal = 50000;
  final TextEditingController _nominalController = TextEditingController(text: "50.000");

  String _metode = "Transfer Bank BCA";
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _periodeBulan = _listBulan[DateTime.now().month - 1]; // otomatis set bulan saat ini
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nik = prefs.getString('nik_user') ?? '';
    if(nik.isEmpty) return;
    
    try {
       final res = await http.get(Uri.parse("${ApiUrl.getProfilByNik}?nik=$nik"));
       if(res.statusCode == 200) {
          final data = json.decode(res.body);
          if(data['status'] == 'success') {
             if (mounted) {
               setState(() {
                  _namaKepala = data['data']['nama_kepala'] ?? data['data']['nama'];
                  _noKk = data['data']['no_kk'] ?? '-';
                  _idKeluarga = data['data']['id_keluarga'].toString();
                  _idUser = data['data']['id_user']?.toString() ?? "";
               });
             }
          }
       }
    } catch(e) {
       debugPrint("Err profil: $e");
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _submitBayar() async {
    if (_idKeluarga.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data validasi Kepala Keluarga belum termuat! Pastikan NIK terdaftar di aplikasi!")));
      return;
    }
    if (_nominal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Masukan nominal pembayaran!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var request = http.MultipartRequest('POST', Uri.parse(ApiUrl.postIuran));
      request.fields['id_keluarga'] = _idKeluarga;
      request.fields['id_user'] = _idUser.isNotEmpty ? _idUser : (prefs.getString('id_user') ?? '1');
      request.fields['jenis_iuran'] = _jenisIuran;
      request.fields['bulan'] = _periodeBulan;
      request.fields['tahun'] = DateTime.now().year.toString();
      request.fields['nominal'] = _nominal.toString();
      request.fields['metode_pembayaran'] = _metode;
      request.fields['catatan'] = "Pembayaran $_jenisIuran bulan $_periodeBulan";

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('bukti_transfer', _imageFile!.path));
      } else if (_metode != "Tunai") {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bukti transfer berupa foto / screenshot struk wajib diunggah.")));
        setState(() => _isLoading = false);
        return;
      }

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      debugPrint("RAW RESP BAYAR: $responseData");
      
      Map<String, dynamic> jsonRes;
      try {
        jsonRes = json.decode(responseData);
      } catch(e) {
         if (responseData.toLowerCase().contains("post content-length")) {
            throw Exception("Kapasitas foto file terlalu besar! Silakan compress dulu.");
         }
         throw Exception("Respon server bukan JSON: " + (responseData.length > 80 ? responseData.substring(0,80) : responseData));
      }

      if (jsonRes['status'] == 'success') {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Pembayaran sukses! Menampilkan resi...")));
           
           Map<String, dynamic> freshData = {
               'status': 'pending', 
               'transaction_id': jsonRes['transaction_id'] ?? '-',
               'jenis_iuran': _jenisIuran,
               'bulan': _periodeBulan,
               'tahun': DateTime.now().year.toString(),
               'nominal': _nominal.toString(),
               'metode_pembayaran': _metode,
               'tanggal_bayar': DateTime.now().toIso8601String(),
               'nama_kepala': _namaKepala,
               'bukti_transfer': null, 
               'bukti_transfer_local': _imageFile?.path,
           };

           Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => UserDetailPage(iuranData: freshData))
           );
        }
      } else {
        throw Exception(jsonRes['message'] ?? 'Internet atau server bermasalah');
      }
    } catch (e) {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _setNominal(int val) {
    setState(() {
      _nominal = val;
      _nominalController.text = NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(val);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // Persis krem desain
      body: Stack(
        children: [
          // Background watermark house memudar persis di slide tengah
          Positioned(
             top: 250, left: 0, right: 0,
             child: Opacity(
                opacity: 0.1, // Dibuat 10% biar nggak terlalu nutupin text
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_ert.png',
                    height: 280,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/logo.png', // Fallback kalo logo_ert nggak ada
                        height: 280,
                        errorBuilder: (c,e,s) => const SizedBox(),
                      );
                    },
                  ),
                ),
             ),
          ),
          
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderAndTabsNav(),
                  
                  // Kotak Profil Kepala Keluarga ngangkang overlapping background Ijo
                  Transform.translate(
                    offset: const Offset(0, -35),
                    child: _buildProfileInfoCard(),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("Jenis Iuran"),
                        _buildModernDropdown(_jenisIuran, _listJenis, (v) => setState(()=>_jenisIuran=v!)),
                        const SizedBox(height: 18),

                        _buildSectionLabel("Periode Bulan"),
                        _buildModernDropdown(_periodeBulan, _listBulan, (v) => setState(()=>_periodeBulan=v!)),
                        const SizedBox(height: 18),

                        _buildSectionLabel("Nominal Pembayaran"),
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: [
                              _buildNominalQuickChip(20000, "20rb"),
                              const SizedBox(width: 10),
                              _buildNominalQuickChip(50000, "50rb"),
                              const SizedBox(width: 10),
                              _buildNominalQuickChip(100000, "100rb"),
                           ]
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nominalController,
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                             String numeric = val.replaceAll(RegExp(r'[^0-9]'), '');
                             if(numeric.isNotEmpty) {
                                _nominal = int.parse(numeric);
                             } else {
                                _nominal = 0;
                             }
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 25),
                        
                        _buildSectionLabel("Metode Pembayaran"),
                        _buildPaymentMethodOption("BCA", "Transfer Bank (BCA)", "Otomatis Terverifikasi", Colors.blue.shade100, Colors.blue.shade700, "Transfer Bank BCA"),
                        const SizedBox(height: 12),
                        _buildPaymentMethodOption("MAN", "Transfer Mandiri", "Cek Manual 1-2 Jam", Colors.orange.shade100, Colors.orange.shade800, "Transfer Bank Mandiri"),
                        const SizedBox(height: 12),
                        _buildPaymentMethodOption("tunai", "Bayar Tunai", "Hubungi Bendahara RT", Colors.green.shade100, Colors.green.shade700, "Tunai", iconData: Icons.account_balance_wallet_outlined),
                        const SizedBox(height: 25),
                        
                        _buildSectionLabel("Upload Bukti Transfer"),
                        _buildUploadImageZone(),
                        
                        const SizedBox(height: 35),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitBayar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7CB342),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 0,
                            ),
                            child: _isLoading 
                               ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) 
                               : const Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          )
                        ),
                        const SizedBox(height: 40), // Spacer bawah
                      ]
                    )
                  )
                ],
              ),
            )
          )
        ],
      )
    );
  }

  // --- KOMPONEN UI --- //

  Widget _buildSectionLabel(String txt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(txt, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Color(0xFF4A4A4A))),
    );
  }

  Widget _buildModernDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildNominalQuickChip(int amount, String label) {
    bool isSelected = _nominal == amount;
    return Expanded(
      child: GestureDetector(
        onTap: () => _setNominal(amount),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? const Color(0xFF7CB342) : Colors.transparent, width: 2),
            boxShadow: [if (!isSelected) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF7CB342) : Colors.black87, fontSize: 13)),
        )
      )
    );
  }

  Widget _buildPaymentMethodOption(String shortMark, String title, String subtitle, Color bgColor, Color textColor, String dataVal, {IconData? iconData}) {
    bool isSel = _metode == dataVal;
    return GestureDetector(
      onTap: () => setState(() => _metode = dataVal),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: isSel ? const Color(0xFFF7FDF5) : Colors.white, 
          border: Border.all(color: isSel ? const Color(0xFF8CAF5D) : Colors.transparent, width: 1.5),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [if (!isSel) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              height: 45, width: 45,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: iconData != null 
                 ? Icon(iconData, color: textColor)
                 : Text(shortMark, style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2C3E50))),
                   const SizedBox(height: 3),
                   Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
                ],
              )
            ),
            Container(
               width: 22, height: 22,
               decoration: BoxDecoration(
                  color: isSel ? Colors.green : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSel ? Colors.green.shade200 : Colors.grey.shade300, width: isSel ? 5 : 2),
               ),
            )
          ],
        )
      )
    );
  }

  Widget _buildUploadImageZone() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: CustomPaint(
          painter: _DashedRectPainter(),
          child: Center(
            child: Column(
              children: [
                if (_imageFile == null) ... [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.broken_image_outlined, color: Colors.green.shade600, size: 30),
                  ),
                  const SizedBox(height: 12),
                  const Text("Unggah Bukti Transfer", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2C3E50))),
                  const SizedBox(height: 4),
                  const Text("Pastikan nominal dan tanggal transfer\nterlihat jelas", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 10)),
                ] else ... [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_imageFile!, height: 120)
                  ),
                  const SizedBox(height: 12),
                  const Text("Foto berhasil dipilih (Ketuk untuk ganti)", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ]
              ],
            )
          )
        )
      )
    );
  }

  Widget _buildHeaderAndTabsNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C2B14),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))], // glow biru tipu tipu biru
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                 decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1.5)),
                 child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                 decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(20)),
                 child: const Text("Bayar Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 26), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: (){})
            ],
          ),
          const SizedBox(height: 35),
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                      width: 130, height: 35,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFE99625), borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20))),
                      child: const Text("<  Bayar Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                   ),
                   const SizedBox(width: 45), // Jarak icon dompet
                   GestureDetector(
                     onTap: () {
                         Navigator.pop(context, true); // Diganti jadi pop(true) biar riwayat lama nggak numpuk dan terefresh
                     },
                     child: Container(
                        width: 130, height: 35,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFE99625), borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
                        child: const Text("Riwayat Iuran  >", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                     ),
                   )
                ],
              ),
              // Icon dompet di overlap persis di tengah
              Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(color: const Color(0xFF0C2B14), border: Border.all(color: Colors.white, width: 1.5), shape: BoxShape.circle),
                 child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 28),
              ),
            ]
          )
        ]
      )
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(20),
      // Efek cahaya/glow tipis kayak di desain biru cyan ngawang wkwk
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.lightBlueAccent.withValues(alpha: 0.4), blurStyle: BlurStyle.outer, blurRadius: 25, spreadRadius: 3)],
      ),
      child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
            const Text("NAMA KEPALA KELUARGA", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_namaKepala, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 15),
            const Text("NO. KK", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_noKk, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 17, fontWeight: FontWeight.w900)),
         ],
      )
    );
  }
}

// Custom Painter buat garis putus-putus manual (simpel aja Solid karena keterbatasan standar core Canvas dart tipis-tipis gpp)
class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.grey.shade300..strokeWidth = 2..style = PaintingStyle.stroke;
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0,0,size.width,size.height), const Radius.circular(20)));
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

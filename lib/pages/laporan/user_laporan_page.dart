import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../core/constants/api_url.dart';
import 'user_detail_laporan_page.dart';

class UserLaporanPage extends StatefulWidget {
  const UserLaporanPage({super.key});

  @override
  State<UserLaporanPage> createState() => _UserLaporanPageState();
}

class _UserLaporanPageState extends State<UserLaporanPage> {
  bool _isBuatLaporan = true; // true = Form, false = List Laporanku
  
  final TextEditingController _subjekController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  
  String _kategori = "Pilih Kategori";
  final List<String> _listKategori = ["Pilih Kategori", "Kebersihan", "Infrastruktur", "Keamanan", "Sosial", "Lainnya"];
  
  File? _imageFile;
  bool _isLoading = false;
  
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nik = prefs.getString('nik_user') ?? '';
    if(nik.isEmpty) return;

    try {
      final res = await http.get(Uri.parse("${ApiUrl.getLaporan}?nik=$nik"));
      if(res.statusCode == 200) {
        var data = json.decode(res.body);
        if(data['status'] == 'success') {
          if (mounted) setState(() => _historyList = data['data']);
        }
      }
    } catch(e) {
      debugPrint("Err Laporan: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if(pickedFile == null) return;
    setState(() => _imageFile = File(pickedFile.path));
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (BuildContext ctxt) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text("Pilih Sumber Foto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF7CB342), size: 28),
                title: const Text('Buka Galeri HP', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(ctxt).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const Divider(color: Colors.black12, height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF7CB342), size: 28),
                title: const Text('Jepret Langsung', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(ctxt).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitLaporan() async {
    if(_subjekController.text.isEmpty || _kategori == "Pilih Kategori" || _detailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua form wajib!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String nik = prefs.getString('nik_user') ?? '';

      var request = http.MultipartRequest('POST', Uri.parse(ApiUrl.postLaporan));
      request.fields['nik'] = nik;
      request.fields['subjek'] = _subjekController.text;
      request.fields['kategori'] = _kategori;
      request.fields['detail'] = _detailController.text;
      request.fields['lokasi'] = _lokasiController.text;

      if(_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_bukti', _imageFile!.path));
      }

      var res = await request.send();
      var respStr = await res.stream.bytesToString();
      var data = json.decode(respStr);
      
      if(data['status'] == 'success') {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Laporan berhasil dikirim!")));
           _subjekController.clear();
           _detailController.clear();
           setState(() {
             _imageFile = null;
             _kategori = "Pilih Kategori";
             _isBuatLaporan = false; // Switch to history seamlessly
           });
           _fetchLaporan(); // Reload table
        }
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
       if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Dark green background matching the top portion
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 50), // padding to separate white list
                  decoration: const BoxDecoration(
                    color: Color(0xFF0C2B14), // Dark Green Background
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 250, left: 0, right: 0,
                        child: Opacity(
                          opacity: 0.2, // Ditingkatkan dari 0.08 biar lebih keliatan
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_ert.png',
                              height: 350,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      SafeArea(
                        bottom: false,
                        child: Column(
                          children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        
                        // Floating Tab box container
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CAF5D), // Light green box
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Sampaikan kendala di\nlingkunganmu langsung ke\npengurus RT.", style: TextStyle(color: Color(0xFF0C2B14), fontSize: 18, fontWeight: FontWeight.w900, height: 1.2)),
                              const SizedBox(height: 12),
                              const Text("Laporan Anda akan segera ditinjau oleh petugas\nberwenang.", style: TextStyle(color: Color(0xFFE8F5E9), fontSize: 12)),
                              const SizedBox(height: 35),
                              Row(
                                children: [
                                  Expanded(child: _buildTabButton("Buat Laporan", _isBuatLaporan, () => setState(()=>_isBuatLaporan=true))),
                                  Expanded(child: _buildTabButton("Laporanku", !_isBuatLaporan, () => setState(()=>_isBuatLaporan=false))),
                                ],
                              )
                            ],
                          )
                        ),
                        
                        // Form fields if Buat Laporan is active
                        if(_isBuatLaporan) ... [
                           const SizedBox(height: 30),
                           Padding(
                             padding: const EdgeInsets.symmetric(horizontal: 20),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 _buildLabel("Subjek Laporan"),
                                 _buildTextField(_subjekController, "Contoh: Pipa Jalan Bocor", maxLines: 1),
                                 const SizedBox(height: 15),
                                 
                                 _buildLabel("Kategori"),
                                 _buildDropdown(),
                                 const SizedBox(height: 15),

                                 _buildLabel("Detail Laporan"),
                                 _buildTextField(_detailController, "Tuliskan detail kendala yang dialami...", maxLines: 4),
                                 const SizedBox(height: 15),

                                 _buildLabel("Lampirkan Foto Bukti"),
                                 _buildImageUploadBox(),
                                 const SizedBox(height: 15),

                                 _buildLabel("Lokasi Kejadian"),
                                 _buildLocationBox(),
                                 const SizedBox(height: 30),

                                 SizedBox(
                                   width: double.infinity,
                                   child: ElevatedButton.icon(
                                     onPressed: _isLoading ? null : _submitLaporan,
                                     icon: const Icon(Icons.send, color: Colors.white, size: 18),
                                     label: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                     style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF031607), // Extremely dark green button
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 5,
                                     ),
                                   )
                                 ),
                               ],
                             )
                           )
                        ]
                      ],
                    )
                  ),
                ],
              )
            )
              ]
            ),
            
            // Bottom White Area: "Laporan Terkini" / History
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 30, 25, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     _isBuatLaporan ? "Laporan Terkini" : "Semua Laporanku", 
                     style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 17, fontWeight: FontWeight.w900)
                   ),
                   const SizedBox(height: 15),
                   
                   _historyList.isEmpty 
                      ? const Center(child: Padding(padding: EdgeInsets.only(top:20), child: Text("Belum ada laporan", style: TextStyle(color: Colors.grey))))
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _isBuatLaporan ? (_historyList.length > 3 ? 3 : _historyList.length) : _historyList.length,
                          itemBuilder: (context, index) {
                            return _buildHistoryCard(context, _historyList[index]);
                          }
                        )
                ],
              )
            )
          ]
        ),
      )
    );
  }

  // == WIDGET COMPONENTS ==

  Widget _buildLabel(String txt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)), // All inputs are inside Dark Green
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black12, fontSize: 13, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _kategori,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: _listKategori.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: e == "Pilih Kategori" ? Colors.black26 : Colors.black87)))).toList(),
          onChanged: (v) => setState(() => _kategori = v!),
        ),
      ),
    );
  }

  Widget _buildImageUploadBox() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(
          painter: DashedLightPainter(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(_imageFile == null) ... [
                 Icon(Icons.camera_alt_outlined, color: Colors.blueGrey.shade300, size: 30),
                 const SizedBox(height: 10),
                 Text("Ambil atau Unggah Foto", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11, fontWeight: FontWeight.bold)),
              ] else ... [
                 ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFile!, height: 80, width: 80, fit: BoxFit.cover)),
                 const SizedBox(height: 10),
                 const Text("Foto siap diunggah", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ]
            ],
          )
        )
      )
    );
  }

  Widget _buildLocationBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFF6F8F5), borderRadius: BorderRadius.circular(12)), // Light gray/beige inner
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.location_on_outlined, color: Color(0xFF7CB342), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _lokasiController,
              maxLines: null,
              style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 13, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                 labelText: "ALAMAT LENGKAP LOKASI (Bisa Diubah)",
                 labelStyle: TextStyle(color: Colors.blueGrey, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                 border: InputBorder.none,
                 floatingLabelBehavior: FloatingLabelBehavior.always,
                 contentPadding: EdgeInsets.symmetric(vertical: 15),
                 hintText: "Ketik jalan, blok, gang...",
                 hintStyle: TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.normal),
              ),
            )
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.blueGrey, size: 20),
            tooltip: 'Deteksi Lokasi Menggunakan Satelit GPS Asli',
            onPressed: () async {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sedang menyambung ke satelit GPS...")));
               try {
                 bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                 if (!serviceEnabled) {
                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Sistem GPS di hp kamu mati! Nyalakan dulu.")));
                   return;
                 }
                 LocationPermission permission = await Geolocator.checkPermission();
                 if (permission == LocationPermission.denied) {
                   permission = await Geolocator.requestPermission();
                   if (permission == LocationPermission.denied) {
                     if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Lu nolak izin GPS wkwkwk!")));
                     return;
                   }
                 }
                 if (permission == LocationPermission.deniedForever) {
                   if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text("Lu blokir permanen izin GPS nya tuh. Buka pengaturan hp.")));
                   return;
                 }

                 Position position = await Geolocator.getCurrentPosition();
                 List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
                 if (placemarks.isNotEmpty) {
                   Placemark place = placemarks[0];
                   String address = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
                   
                   // Clean up empty fields if null
                   address = address.replaceAll(RegExp(r', ,'), ','); 
                   
                   if (mounted) {
                      setState(() {
                         _lokasiController.text = address;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Titik GPS Acquired!")));
                   }
                 }
               } catch (e) {
                 if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Err GPS: $e")));
               }
            },
          )
        ],
      )
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item) {
    String subjek = item['subjek'] ?? '';
    String kategori = item['kategori'] ?? '';
    String tglStr = item['tanggal_laporan'] ?? '';
    String status = item['status'] ?? 'TERKIRIM';
    
    // Formatting date
    String displayDate = tglStr;
    try {
       DateTime dt = DateTime.parse(tglStr);
       displayDate = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch(e) {}

    Color chipBg = const Color(0xFFF1F6FD);
    Color chipTxt = const Color(0xFF4A90E2);
    if(status == 'DIPROSES') { chipBg = const Color(0xFFFFF6EB); chipTxt = const Color(0xFFF39C12); }
    else if(status == 'SELESAI') { chipBg = const Color(0xFFEBF6EC); chipTxt = const Color(0xFF2ECC71); }
    else if(status == 'DITOLAK') { chipBg = const Color(0xFFFFEBEE); chipTxt = Colors.red; }

    return GestureDetector(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailLaporanPage(laporanData: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
           color: const Color(0xFFFAF9F6), // Light beige box
           borderRadius: BorderRadius.circular(15),
           boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subjek, style: const TextStyle(color: Color(0xFF1B232E), fontSize: 14, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 5),
                  Text("$displayDate • $kategori", style: const TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              )
            ),
            Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)),
               child: Text(status, style: TextStyle(color: chipTxt, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            )
          ],
        )
      )
    );
  }

  Widget _buildTabButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // expand hit area
        child: Column(
          children: [
            Text(text, style: TextStyle(color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Container(height: 2, width: double.infinity, color: isActive ? Colors.white : Colors.transparent)
          ],
        )
      )
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Container(
             decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5)),
             child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
             decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(20)),
             child: const Text("Laporan & Aduan", style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
           ),
           const SizedBox(width: 40),
        ],
      )
    );
  }
}

class DashedLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.lightBlue.withValues(alpha: 0.2)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2,2,size.width-4,size.height-4), const Radius.circular(10)));
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter old) => false;
}

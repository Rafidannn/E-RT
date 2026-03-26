import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/constants/api_url.dart';
import 'user_detail_surat_page.dart';

class UserSuratPage extends StatefulWidget {
  const UserSuratPage({super.key});

  @override
  State<UserSuratPage> createState() => _UserSuratPageState();
}

class _UserSuratPageState extends State<UserSuratPage> {
  String _namaUser = "Memuat...";
  String _nikUser = "Memuat...";
  
  String _jenisSurat = "Pengantar KTP/KK";
  final List<String> _listJenisSurat = ["Pengantar KTP/KK", "Pengantar SKCK", "Keterangan Domisili", "Surat Izin Usaha", "Lainnya"];
  
  final TextEditingController _keperluanController = TextEditingController();
  
  File? _imageFile;
  String _metodePengambilan = "Fisik";
  
  bool _isLoading = false;
  List<dynamic> _historyList = [];

  @override
  void initState() {
    super.initState();
    _loadProfileAndHistory();
  }

  Future<void> _loadProfileAndHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
       _namaUser = prefs.getString('nama_user') ?? 'Warga ERT';
       _nikUser = prefs.getString('nik_user') ?? '-';
    });
    
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    if (_nikUser == '-') return;
    try {
      final res = await http.get(Uri.parse("${ApiUrl.getSurat}?nik=$_nikUser"));
      if(res.statusCode == 200) {
        var data = json.decode(res.body);
        if(data['status'] == 'success') {
          if (mounted) setState(() => _historyList = data['data']);
        }
      }
    } catch(e) {
      debugPrint("Err Surat: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if(pickedFile == null) return;
    setState(() => _imageFile = File(pickedFile.path));
  }

  void _showImageSourceActionSheet() {
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
                child: Text("Pilih Sumber Dokumen", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF7CB342), size: 28),
                title: const Text('Buka Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { Navigator.of(ctxt).pop(); _pickImage(ImageSource.gallery); },
              ),
              const Divider(color: Colors.black12, height: 1),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Color(0xFF7CB342), size: 28),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () { Navigator.of(ctxt).pop(); _pickImage(ImageSource.camera); },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }
    );
  }

  Future<void> _submitSurat() async {
    if(_keperluanController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isikan keperluan surat!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiUrl.postSurat));
      request.fields['nik'] = _nikUser;
      request.fields['jenis_surat'] = _jenisSurat;
      request.fields['keperluan'] = _keperluanController.text;
      request.fields['metode_pengambilan'] = _metodePengambilan;

      if(_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('file_lampiran', _imageFile!.path));
      }

      var res = await request.send();
      var respStr = await res.stream.bytesToString();
      var data = json.decode(respStr);
      
      if(data['status'] == 'success') {
        if(mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.green, content: Text("Permohonan surat berhasil diajukan!")));
           _keperluanController.clear();
           setState(() { _imageFile = null; _metodePengambilan = "Fisik"; });
           _fetchHistory();
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
      body: Stack(
        children: [
          // Background Header
          Container(
            height: 380,
            width: double.infinity,
            decoration: const BoxDecoration(
               color: Color(0xFF0C2B14),
               borderRadius: BorderRadius.vertical(bottom: Radius.circular(55))
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 25),
                  
                  // Ajukan Permohonan Texts
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Ajukan Permohonan", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Text("Ajukan permohonan surat pengantar tanpa harus\nkeluar rumah.", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, height: 1.4)),
                        const SizedBox(height: 25),
                        
                        // ID Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                             gradient: const LinearGradient(colors: [Color(0xFF0D324D), Color(0xFF1B5E20)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                             borderRadius: BorderRadius.circular(15),
                             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))]
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                               Positioned(
                                 right: -50, bottom: -50,
                                 child: Container(width: 150, height: 150, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)))
                               ),
                               Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                         Icon(Icons.fingerprint, color: Colors.blue.shade200, size: 28),
                                         Text("IDENTITAS TERVERIFIKASI", style: TextStyle(color: Colors.blue.shade100, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5))
                                      ]
                                    ),
                                    const SizedBox(height: 25),
                                    const Text("NAMA PELAPOR", style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(_namaUser, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 15),
                                    const Text("NIK", style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                    const SizedBox(height: 4),
                                    Text(_nikUser, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 2)),
                                 ]
                               )
                            ]
                          )
                        )
                      ]
                    )
                  ),
                  
                  const SizedBox(height: 35),
                  
                  // Formulir Pengajuan Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Row(
                           children: [
                             const Icon(Icons.edit_document, color: Color(0xFF4A90E2), size: 18),
                             const SizedBox(width: 10),
                             const Text("Formulir Pengajuan", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 14, fontWeight: FontWeight.w900)),
                           ]
                         ),
                         const SizedBox(height: 25),
                         
                         _buildLabel("Jenis Surat"),
                         _buildDropdown(),
                         const SizedBox(height: 20),
                         
                         _buildLabel("Keperluan"),
                         _buildTextField(_keperluanController, "Contoh: Untuk persyaratan menikah...", maxLines: 3),
                         const SizedBox(height: 20),
                         
                         _buildLabel("Unggah Foto KTP/KK (Opsional)"),
                         _buildImageUploadBox(),
                         const SizedBox(height: 20),

                         _buildLabel("Metode Pengambilan"),
                         _buildRadioOption("Ambil Fisik di Ketua RT", "Datang langsung ke alamat RT", "Fisik"),
                         const SizedBox(height: 12),
                         _buildRadioOption("Kirim File Digital (PDF)", "Unduh melalui aplikasi ini", "Digital"),
                         const SizedBox(height: 30),

                         SizedBox(
                           width: double.infinity,
                           child: ElevatedButton.icon(
                             onPressed: _isLoading ? null : _submitSurat,
                             icon: const Icon(Icons.send, color: Colors.white, size: 18),
                             label: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) : const Text("Ajukan Surat", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                             style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF031607), 
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 3,
                             ),
                           )
                         ),
                      ]
                    )
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Riwayat Pengajuan Lists
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         const Text("Riwayat Pengajuan", style: TextStyle(color: Color(0xFF2C3E50), fontSize: 15, fontWeight: FontWeight.w900)),
                         const Text("Lihat Semua", style: TextStyle(color: Color(0xFF5A9B6B), fontSize: 11, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                      ]
                    )
                  ),
                  
                  const SizedBox(height: 15),
                  
                  _historyList.isEmpty 
                    ? const Center(child: Padding(padding: EdgeInsets.only(top:20, bottom: 50), child: Text("Belum ada pengajuan surat", style: TextStyle(color: Colors.grey))))
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _historyList.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(context, _historyList[index]);
                        }
                      )
                ]
              )
            )
          )
        ]
      )
    );
  }

  // == WIDGET COMPONENTS ==

  Widget _buildLabel(String txt) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(txt, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Color(0xFF2C3E50))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26, fontSize: 12, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7CB342), width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _jenisSurat,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, color: Colors.grey),
          items: _listJenisSurat.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)))).toList(),
          onChanged: (v) => setState(() => _jenisSurat = v!),
        ),
      ),
    );
  }

  Widget _buildImageUploadBox() {
    return GestureDetector(
      onTap: () => _showImageSourceActionSheet(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(
          painter: DashedLightPainter(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(_imageFile == null) ... [
                 const Icon(Icons.cloud_upload_outlined, color: Colors.blueGrey, size: 30),
                 const SizedBox(height: 10),
                 const Text("Klik atau seret file ke sini", style: TextStyle(color: Colors.blueGrey, fontSize: 11, fontWeight: FontWeight.bold)),
                 const SizedBox(height: 5),
                 const Text("JPG, PNG, PDF (Maks. 2MB)", style: TextStyle(color: Colors.black26, fontSize: 9)),
              ] else ... [
                 ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.file(_imageFile!, height: 80, width: 80, fit: BoxFit.cover)),
                 const SizedBox(height: 10),
                 const Text("Dokumen siap diunggah", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
              ]
            ],
          )
        )
      )
    );
  }

  Widget _buildRadioOption(String title, String subtitle, String value) {
    bool isSelected = _metodePengambilan == value;
    return GestureDetector(
      onTap: () => setState(() => _metodePengambilan = value),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
           color: Colors.transparent,
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: isSelected ? const Color(0xFF1E3C28) : Colors.black12, width: isSelected ? 1.5 : 1)
        ),
        child: Row(
          children: [
             Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF0C2B14) : Colors.grey, size: 20),
             const SizedBox(width: 15),
             Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(title, style: TextStyle(color: isSelected ? const Color(0xFF1E3C28) : Colors.black87, fontWeight: FontWeight.w900, fontSize: 12)),
                 const SizedBox(height: 2),
                 Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 9)),
               ]
             )
          ]
        )
      )
    );
  }

  Widget _buildHistoryCard(BuildContext context, dynamic item) {
    String jenis = item['jenis_surat'] ?? '';
    String tglStr = item['tanggal_pengajuan'] ?? '';
    String status = item['status'] ?? 'MENUNGGU';
    String catatan = item['catatan_admin'] ?? '';
    
    String displayDate = tglStr;
    try {
       DateTime dt = DateTime.parse(tglStr);
       displayDate = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch(e) {}

    Color sideColor = const Color(0xFFFFC107);
    Color chipBg = const Color(0xFFFFF8E1);
    Color chipTxt = const Color(0xFFF57F17);
    String datePrefix = "Diajukan: ";

    if(status == 'DISETUJUI') { 
      sideColor = const Color(0xFF2ECC71); 
      chipBg = const Color(0xFFE8F8F5); 
      chipTxt = const Color(0xFF27AE60); 
      datePrefix = "Disetujui: ";
    } else if(status == 'DITOLAK') { 
      sideColor = const Color(0xFFE74C3C); 
      chipBg = const Color(0xFFFDEDEC); 
      chipTxt = const Color(0xFFC0392B); 
      datePrefix = "Ditolak: ";
    }

    return GestureDetector(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailSuratPage(suratData: item)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: sideColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text(jenis, style: const TextStyle(color: Color(0xFF2C3E50), fontSize: 13, fontWeight: FontWeight.w900)),
                                 const SizedBox(height: 5),
                                 Text("$datePrefix$displayDate", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                               ]
                            )
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                 decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(20)),
                                 child: Text(status, style: TextStyle(color: chipTxt, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                               ),
                               if(status == 'DISETUJUI') ... [
                                 const SizedBox(height: 8),
                                 Row(
                                   children: const [
                                     Icon(Icons.download, color: Color(0xFF27AE60), size: 10),
                                     SizedBox(width: 4),
                                     Text("Unduh PDF", style: TextStyle(color: Color(0xFF27AE60), fontSize: 9, fontWeight: FontWeight.w700))
                                   ]
                                 )
                               ]
                            ]
                          )
                        ]
                      ),
                      if(status == 'DITOLAK' && catatan.isNotEmpty) ... [
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFFDEDEC), borderRadius: BorderRadius.circular(8)),
                          child: Text(catatan, style: const TextStyle(color: Color(0xFFC0392B), fontSize: 10, fontStyle: FontStyle.italic)),
                        )
                      ]
                    ]
                  )
                )
              )
            ]
          )
        )
      )
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Container(
             decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
             child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 40, minHeight: 40)),
           ),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 8),
             decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(20)),
             child: const Text("Surat Pengantar", style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
           ),
           IconButton(icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 26), onPressed: (){}),
        ],
      )
    );
  }
}

class DashedLightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Colors.blueGrey.withOpacity(0.2)..strokeWidth = 1.5..style = PaintingStyle.stroke;
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2,2,size.width-4,size.height-4), const Radius.circular(10)));
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(covariant CustomPainter old) => false;
}

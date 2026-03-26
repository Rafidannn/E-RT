import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class JumantikPage extends StatefulWidget {
  const JumantikPage({super.key});

  @override
  State<JumantikPage> createState() => _JumantikPageState();
}

class _JumantikPageState extends State<JumantikPage> {
  List<dynamic> _listKeluarga = [];
  List<dynamic> _listAdmin = [];
  
  String? _selectedKeluargaId;
  String? _selectedKeluargaNama;
  String? _selectedKeluargaAlamat;

  String? _selectedPetugasId;
  String? _selectedPetugasNama;

  String _statusJentik = "tidak"; // 'ada' or 'tidak'
  String? _selectedWadah;
  
  final TextEditingController _catatanCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  
  XFile? _fotoBukti;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isLoadingKeluarga = false;

  @override
  void initState() {
    super.initState();
    _fetchKeluarga();
    _fetchAdmin();
    _loadInitialPetugas();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialPetugas() async {
    final prefs = await SharedPreferences.getInstance();
    // Default null or assigned if role logic dictates, leaving to dropdown to select.
    setState(() {
       _selectedPetugasId = prefs.getString('id_user') ?? prefs.getString('id');
    });
  }

  Future<void> _fetchKeluarga() async {
    setState(() => _isLoadingKeluarga = true);
    try {
      final response = await ApiService.get(ApiUrl.getKeluarga); // get all families to get address
      if (response['status'] == 'success' || response['status'] == true) {
        setState(() {
          _listKeluarga = response['data'] ?? [];
        });
      } else {
        // Fallback to simpler ones if getKeluarga returns standard
        final backupRes = await ApiService.get(ApiUrl.listKeluargaDropdown);
        if (backupRes['status'] == true || backupRes['status'] == 'success') {
           setState(() => _listKeluarga = backupRes['data']);
        }
      }
    } catch (e) {
      debugPrint("Error Keluarga: $e");
    } finally {
      if (mounted) setState(() => _isLoadingKeluarga = false);
    }
  }

  Future<void> _fetchAdmin() async {
    try {
      final response = await ApiService.get("${ApiUrl.baseUrl}/auth/get_admin.php");
      if (response['status'] == true || response['status'] == 'success') {
        setState(() {
          _listAdmin = response['data'] ?? [];
          if (_selectedPetugasId != null) {
            final admin = _listAdmin.firstWhere((a) => a['id_user'].toString() == _selectedPetugasId, orElse: () => null);
            if (admin != null) {
              _selectedPetugasNama = admin['nama'];
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error Admin: $e");
    }
  }

  Future<void> _simpanLaporan() async {
    if (_selectedKeluargaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih keluarga terlebih dahulu dari kolom pencarian!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);
    
    String? fotoBase64;
    try {
      if (_fotoBukti != null) {
         final bytes = await _fotoBukti!.readAsBytes();
         fotoBase64 = base64Encode(bytes);
      }
    } catch(e) {
      debugPrint("Gagal encode foto: $e");
    }

    try {
      Map<String, dynamic> data = {
        'id_keluarga': _selectedKeluargaId,
        'status_jentik': _statusJentik,
        'sumber_air': _selectedWadah ?? '',
        'catatan': _catatanCtrl.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'petugas': _selectedPetugasId ?? '1',
      };
      
      if (fotoBase64 != null) {
        data['foto_base64'] = fotoBase64;
      }

      final response = await ApiService.post(ApiUrl.postJumantik, data);

      if (response['status'] == true || response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan Jumantik Berhasil Terkirim"), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${response['message']}"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error System: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showKeluargaSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        List<dynamic> filtered = List.from(_listKeluarga);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))
              ),
              child: Column(
                children: [
                   TextField(
                     autofocus: true,
                     decoration: InputDecoration(
                       hintText: "Cari Nama KK atau Nomor KK...",
                       prefixIcon: const Icon(Icons.search),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
                     ),
                     onChanged: (val) {
                       setModalState(() {
                         filtered = _listKeluarga.where((w) {
                           final nama = w['nama_kepala']?.toString().toLowerCase() ?? w['nama_warga']?.toString().toLowerCase() ?? '';
                           final no = w['no_kk']?.toString().toLowerCase() ?? '';
                           return nama.contains(val.toLowerCase()) || no.contains(val.toLowerCase());
                         }).toList();
                       });
                     },
                   ),
                   const SizedBox(height: 15),
                   Expanded(
                     child: _isLoadingKeluarga
                       ? const Center(child: CircularProgressIndicator())
                       : ListView.builder(
                           itemCount: filtered.length,
                           itemBuilder: (context, index) {
                             final item = filtered[index];
                             final nama = item['nama_kepala'] ?? item['nama_warga'] ?? 'Tanpa Nama';
                             final alamat = item['alamat_lengkap'] ?? item['alamat'] ?? 'Alamat tidak tersedia. Pastikan profil keluarga lengkap.';
                             return ListTile(
                               leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: const Icon(Icons.house, color: Colors.blue)),
                               title: Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                               subtitle: Text(item['no_kk']?.toString() ?? '-'),
                               onTap: () {
                                 setState(() {
                                   _selectedKeluargaId = item['id_keluarga']?.toString();
                                   _selectedKeluargaNama = nama;
                                   _selectedKeluargaAlamat = alamat;
                                 });
                                 Navigator.pop(context);
                               },
                             );
                           },
                         )
                   )
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF334A28), // Background solid
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildPetugasProfile(),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLokasiPemeriksaan(),
                      const SizedBox(height: 25),
                      _buildDetailPemeriksaan(),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _simpanLaporan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF81A949),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: _isLoading ? const SizedBox() : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          label: _isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text("Kirim Laporan Jumantik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF759A3D), borderRadius: BorderRadius.circular(15)),
                child: const Text("Pencatatan Jumantik", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Icon(Icons.person_search_outlined, color: Colors.white, size: 26),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(color: Colors.white54, thickness: 1),
        ),
      ],
    );
  }

  Widget _buildPetugasProfile() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.local_police, color: Colors.blueAccent, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _listAdmin.any((a) => a['id_user'].toString() == _selectedPetugasId) ? _selectedPetugasId : null,
                hint: const Text("Pilih Petugas (Admin)", style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold)),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                isExpanded: true,
                items: _listAdmin.map((a) {
                  return DropdownMenuItem<String>(
                    value: a['id_user'].toString(),
                    child: Text(a['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPetugasId = val;
                    final adm = _listAdmin.firstWhere((e) => e['id_user'].toString() == val, orElse: () => null);
                    if (adm != null) _selectedPetugasNama = adm['nama'];
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiPemeriksaan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Lokasi Pemeriksaan", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E3E34))),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: _showKeluargaSearchDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(_selectedKeluargaNama ?? "Cari Nama KK atau Nomor KK...", style: TextStyle(color: _selectedKeluargaNama == null ? Colors.grey : Colors.black87, fontSize: 12))),
              ],
            ),
          ),
        ),
        if (_selectedKeluargaNama != null) ...[
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: const Color(0xFFF2F9FA), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.withValues(alpha: 0.1))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: Colors.lightBlue, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ALAMAT TERDAFTAR", style: TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 10)),
                      const SizedBox(height: 5),
                      Text(_selectedKeluargaAlamat ?? "Alamat tidak tersedia. Pastikan profil warga lengkap.", style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
                    ],
                  ),
                )
              ],
            ),
          )
        ]
      ],
    );
  }

  Widget _buildDetailPemeriksaan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Detail Pemeriksaan", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF2E3E34))),
        const SizedBox(height: 15),
        const Text("Status Keberadaan Jentik", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildJentikButton("ada", "ADA", Icons.error_outline, Colors.red)),
            const SizedBox(width: 15),
            Expanded(child: _buildJentikButton("tidak", "TIDAK", Icons.check_circle_outline, Colors.blue)),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Sumber Air / Wadah", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightBlue)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            filled: true, fillColor: Colors.white,
          ),
          hint: const Text("Pilih Jenis Wadah", style: TextStyle(fontSize: 12, color: Colors.grey)),
          value: _selectedWadah,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: ["Bak Mandi", "Tempayan", "Ember", "Pot Tanaman", "Dispenser", "Lainnya"]
              .map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 13))))
              .toList(),
          onChanged: (val) => setState(() => _selectedWadah = val),
        ),
        const SizedBox(height: 25),
        const Text("Dokumentasi Temuan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () async {
            final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30, maxWidth: 800);
            if (picked != null) setState(() => _fotoBukti = picked);
          },
          child: CustomPaint(
            painter: _DashedRectPainter(color: Colors.lightBlue.shade200, strokeWidth: 1.5, gap: 5.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  if (_fotoBukti != null)
                     const Icon(Icons.check_circle, color: Colors.green, size: 35)
                  else
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(color: Colors.lightBlue.shade50, shape: BoxShape.circle),
                       child: const Icon(Icons.photo_library_outlined, color: Colors.lightBlue, size: 25),
                     ),
                  const SizedBox(height: 12),
                  Text(_fotoBukti != null ? "Foto Terpilih" : "Pilih Foto Bukti", style: const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text("DARI GALERI", style: TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        const Text("Catatan Tambahan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        TextField(
          controller: _catatanCtrl,
          maxLines: 3,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: "Berikan saran atau edukasi kepada keluarga...",
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.lightBlue)),
            filled: true, fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildJentikButton(String val, String label, IconData icon, Color color) {
    bool isSelected = _statusJentik == val;
    return GestureDetector(
      onTap: () => setState(() => _statusJentik = val),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.05) : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey.shade200, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 28),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color : Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for dashed border box
class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  
  _DashedRectPainter({required this.color, required this.strokeWidth, required this.gap});
  
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
      
    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(10)));
    
    Path dashPath = Path();
    double distance = 0.0;
    
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }
    
    canvas.drawPath(dashPath, paint);
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

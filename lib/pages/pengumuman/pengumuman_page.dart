import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'package:intl/intl.dart';

class PengumumanPage extends StatefulWidget {
  const PengumumanPage({super.key});

  @override
  State<PengumumanPage> createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  String? _selectedKategori;
  
  XFile? _fotoPengumuman;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D4B1E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF2D4B1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
             colorScheme: const ColorScheme.light(
               primary: Color(0xFF2D4B1E),
               onPrimary: Colors.white,
               onSurface: Color(0xFF2D4B1E),
             ),
          ),
          child: child!,
        );
      }
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
         _selectedTime = picked;
      });
    }
  }

  Future<void> _postPengumuman() async {
    setState(() => _isLoading = true);
    
    String? fotoBase64;
    try {
      if (_fotoPengumuman != null) {
         final bytes = await _fotoPengumuman!.readAsBytes();
         fotoBase64 = base64Encode(bytes);
      }
    } catch(e) {
      debugPrint("Gagal encode foto: $e");
    }

    try {
      // Waktu diformat jadi HH:mm WIB
      final String formattedTime = "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB";

      final Map<String, dynamic> formData = {
        'judul': _judulController.text,
        'isi': _isiController.text,
        'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'waktu': formattedTime,
        'kategori': _selectedKategori ?? 'INFO',
        'lokasi': _lokasiController.text.isNotEmpty ? _lokasiController.text : 'Balai Warga',
        'user_id': '1', 
      };

      if (fotoBase64 != null) {
        formData['foto_base64'] = fotoBase64;
      }

      final response = await ApiService.post(ApiUrl.postPengumuman, formData);

      if (response['status'] == true) {
        if (mounted) _showSuccessDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Gagal menyimpan")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Buat Pengumuman',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF2D4B1E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Judul Pengumuman", Icons.title_rounded),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _judulController,
                            hint: "Contoh: Jadwal Kerja Bakti RT 05",
                            maxLines: 1,
                          ),

                          const SizedBox(height: 20),

                          _buildLabel("Kategori Pengumuman", Icons.category_outlined),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF1F4F8),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                            ),
                            hint: const Text("Pilih Kategori", style: TextStyle(color: Colors.grey, fontSize: 13)),
                            value: _selectedKategori,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8BAE51)),
                            items: ["TERBARU", "KESEHATAN", "LINGKUNGAN", "KEAMANAN", "INFO"]
                                .map((w) => DropdownMenuItem(value: w, child: Text(w, style: const TextStyle(fontSize: 14))))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedKategori = val),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     _buildLabel("Tanggal", Icons.calendar_month_rounded),
                                     const SizedBox(height: 10),
                                     InkWell(
                                       onTap: _pickDate,
                                       child: Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                         decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Text(DateFormat('dd MMM yyyy').format(_selectedDate), style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                             const Icon(Icons.edit_calendar_rounded, color: Color(0xFF8BAE51), size: 18),
                                           ],
                                         ),
                                       ),
                                     ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     _buildLabel("Waktu", Icons.access_time_rounded),
                                     const SizedBox(height: 10),
                                     InkWell(
                                       onTap: _pickTime,
                                       child: Container(
                                         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                         decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
                                         child: Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children: [
                                             Expanded(child: Text("${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB", style: const TextStyle(fontSize: 13, color: Colors.black87), overflow: TextOverflow.ellipsis)),
                                             const Icon(Icons.schedule, color: Color(0xFF8BAE51), size: 18),
                                           ],
                                         ),
                                       ),
                                     ),
                                  ],
                                )
                              )
                            ],
                          ),

                          const SizedBox(height: 20),
                          
                          _buildLabel("Lokasi Kegiatan", Icons.location_on_rounded),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _lokasiController,
                            hint: "Contoh: Balai Warga RT 05",
                            maxLines: 1,
                          ),

                          const SizedBox(height: 20),

                          _buildLabel("Foto Banner (Opsional)", Icons.image_rounded),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 30, maxWidth: 600);
                              if (picked != null) setState(() => _fotoPengumuman = picked);
                            },
                            child: CustomPaint(
                              painter: _DashedRectPainter(color: const Color(0xFF8BAE51), strokeWidth: 1.5, gap: 5.0),
                              child: Container(
                                width: double.infinity,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F4F8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: _fotoPengumuman != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.file(File(_fotoPengumuman!.path), fit: BoxFit.cover, width: double.infinity),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)]),
                                            child: const Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF8BAE51), size: 30),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text("Upload Foto dari Galeri", style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildLabel("Isi Pengumuman", Icons.notes_rounded),
                          const SizedBox(height: 10),
                          _buildTextField(
                            controller: _isiController,
                            hint: "Tuliskan detail informasi di sini...",
                            maxLines: 6,
                          ),

                          const SizedBox(height: 35),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : () {
                                if (_formKey.currentState!.validate()) {
                                  _postPengumuman();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8BAE51),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.send_rounded),
                                  SizedBox(width: 10),
                                  Text("PUBLIKASIKAN",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2D4B1E)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2D4B1E))),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required int maxLines}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF1F4F8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text("Berhasil!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 10),
            const Text("Pengumuman telah dipublikasikan.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context, true); // Balik ke Riwayat & kirim sinyal refresh
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D4B1E),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("KEMBALI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
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
    path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(15)));
    
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

import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'riwayat_posyandu_page.dart';

class PosyanduPage extends StatefulWidget {
  const PosyanduPage({super.key});

  @override
  State<PosyanduPage> createState() => _PosyanduPageState();
}

class _PosyanduPageState extends State<PosyanduPage> {
  // --- STATE RIWAYAT ---
  List<dynamic> _listRiwayat = [];
  bool _isLoadingRiwayat = true;

  // --- STATE INPUT ---
  final TextEditingController _beratCtrl = TextEditingController();
  final TextEditingController _tinggiCtrl = TextEditingController();
  final TextEditingController _hasilCtrl = TextEditingController();
  final TextEditingController _searchWargaCtrl = TextEditingController();

  String? _selectedWargaId;
  String? _selectedWargaNama;
  String _selectedKategori = 'balita'; // 'balita' or 'lansia'
  DateTime _tanggalPeriksa = DateTime.now();

  List<dynamic> _listWarga = [];
  bool _isSaving = false;
  bool _isLoadingWarga = true;

  @override
  void initState() {
    super.initState();
    _fetchWarga();
    _fetchRiwayat();
  }

  @override
  void dispose() {
    _beratCtrl.dispose();
    _tinggiCtrl.dispose();
    _hasilCtrl.dispose();
    _searchWargaCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchWarga() async {
    setState(() => _isLoadingWarga = true);
    try {
      final res = await ApiService.get(ApiUrl.getWarga);
      if (res['status'] == 'success') {
        setState(() {
          _listWarga = (res['data'] as List).map((w) {
            return {
              'id_warga': w['id_warga'].toString(),
              'nama': w['nama'],
              'kategori': w['kategori'] ?? 'balita', // optional default
            };
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error Load Warga: $e");
    } finally {
      if (mounted) setState(() => _isLoadingWarga = false);
    }
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final res = await ApiService.get(ApiUrl.getHistoryPosyandu);
      if (res['status'] == true || res['status'] == 'success') {
        setState(() => _listRiwayat = res['data'] ?? []);
      }
    } catch (e) {
      debugPrint("Error Riwayat: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _simpanData() async {
    if (_selectedWargaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Silakan cari dan pilih data warga terlebih dahulu!"), backgroundColor: Colors.red));
      return;
    }
    if (_beratCtrl.text.isEmpty || _tinggiCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mohon lengkapi parameter pengukuran (Berat / Tinggi)"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'id_warga': _selectedWargaId,
        'kategori': _selectedKategori,
        'berat_badan': _beratCtrl.text,
        'tinggi_badan': _tinggiCtrl.text,
        'hasil': _hasilCtrl.text,
        'petugas': '1',
      };

      final res = await ApiService.post(ApiUrl.postPosyandu, data);
      if (res['status'] == true) {
        _fetchRiwayat();
        _beratCtrl.clear();
        _tinggiCtrl.clear();
        _hasilCtrl.clear();
        setState(() { 
          _selectedWargaId = null;
          _selectedWargaNama = null;
          _tanggalPeriksa = DateTime.now();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data Kesehatan Berhasil Disimpan"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? "Gagal menyimpan"), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan sistem"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPeriksa,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6E8E42),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _tanggalPeriksa) {
      setState(() {
        _tanggalPeriksa = picked;
      });
    }
  }

  String _formatDateNumerical(DateTime d) {
    return "${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}";
  }

  void _showWargaSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
         List<dynamic> filtered = List.from(_listWarga);
         return StatefulBuilder(
           builder: (context, setModalState) {
             return Container(
               height: MediaQuery.of(context).size.height * 0.75,
               decoration: const BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.vertical(top: Radius.circular(20))
               ),
               padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   TextField(
                     autofocus: true,
                     decoration: InputDecoration(
                       hintText: "Ketik nama warga...",
                       prefixIcon: const Icon(Icons.search),
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                       contentPadding: const EdgeInsets.symmetric(vertical: 0),
                     ),
                     onChanged: (val) {
                       setModalState(() {
                         filtered = _listWarga.where((w) => w['nama'].toString().toLowerCase().contains(val.toLowerCase())).toList();
                       });
                     },
                   ),
                   const SizedBox(height: 15),
                   Expanded(
                     child: _isLoadingWarga 
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                       itemCount: filtered.length,
                       itemBuilder: (context, index) {
                         final item = filtered[index];
                         return ListTile(
                           leading: CircleAvatar(backgroundColor: Colors.green.shade50, child: const Icon(Icons.person, color: Colors.green)),
                           title: Text(item['nama'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                           onTap: () {
                             setState(() {
                               _selectedWargaId = item['id_warga'];
                               _selectedWargaNama = item['nama'];
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
      backgroundColor: const Color(0xFFFAF7F2), // Light uniform background for the whole screen base
      body: Stack(
        children: [
          // Background Top Green Shape
          Container(
            height: 280,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28), // Dark Green like Riwayat Iuran
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0), // Removed corner radii to match UX mockup (it acts as deep bg)
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                const SizedBox(height: 15),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputCard(),
                          const SizedBox(height: 20),
                          _buildTrendCard(),
                          const SizedBox(height: 25),
                          _buildRiwayatHeader(),
                          const SizedBox(height: 10),
                          _buildRiwayatList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                child: const Text("Pencatatan Posyandu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 26),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: _showWargaSearchDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _selectedWargaNama ?? "Cari nama warga (Balita/Lansia)...",
                  style: TextStyle(
                    color: _selectedWargaNama == null ? Colors.grey : Colors.black87,
                    fontWeight: _selectedWargaNama == null ? FontWeight.normal : FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_selectedWargaNama != null)
                GestureDetector(
                  onTap: () => setState(() {
                    _selectedWargaId = null;
                    _selectedWargaNama = null;
                  }),
                  child: const Icon(Icons.close, color: Colors.grey, size: 20),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Input Data Kesehatan", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF2E3E34))),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKategori = 'balita'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedKategori == 'balita' ? const Color(0xFFF1F8EE) : Colors.white,
                      border: Border.all(color: _selectedKategori == 'balita' ? const Color(0xFF759A3D) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text("Balita", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _selectedKategori == 'balita' ? const Color(0xFF334A28) : Colors.black54)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedKategori = 'lansia'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _selectedKategori == 'lansia' ? const Color(0xFFF1F8EE) : Colors.white,
                      border: Border.all(color: _selectedKategori == 'lansia' ? const Color(0xFF759A3D) : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text("Lansia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _selectedKategori == 'lansia' ? const Color(0xFF334A28) : Colors.black54)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildFormField("BERAT BADAN (KG)", _beratCtrl, "0.0", isNum: true)),
              const SizedBox(width: 15),
              Expanded(child: _buildFormField("TINGGI BADAN (CM)", _tinggiCtrl, "0.0", isNum: true)),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField("CATATAN / HASIL PEMERIKSAAN", _hasilCtrl, "Contoh: Kondisi sehat, nafsu makan baik...", maxLines: 3),
          const SizedBox(height: 20),
          const Text("TANGGAL PERIKSA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDateNumerical(_tanggalPeriksa), style: const TextStyle(fontSize: 14)),
                  const Icon(Icons.edit_calendar, color: Color(0xFF759A3D), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _simpanData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF81A949),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: _isSaving ? const SizedBox() : const Icon(Icons.check, color: Colors.white, size: 20),
              label: _isSaving
                 ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                 : const Text("Simpan Data Kesehatan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl, String hint, {int maxLines = 1, bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF759A3D))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Tren Berat Badan", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF2E3E34))),
              Text("6 Bulan Terakhir", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text("9.6", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text("9.2", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text("8.8", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text("8.4", style: TextStyle(fontSize: 9, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text("8.0", style: TextStyle(fontSize: 9, color: Colors.grey)),
                ]
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: CustomPaint(painter: _TrendChartPainter([8.2, 8.5, 8.9, 9.2, 9.1, 9.5])),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun"].map((m) => Text(m, style: const TextStyle(fontSize: 9, color: Colors.grey))).toList(),
                    )
                  ]
                )
              )
            ]
          )
        ],
      )
    );
  }

  Widget _buildRiwayatHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Riwayat Terbaru", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF2E3E34))),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RiwayatPosyanduPage()));
          },
          child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF00A896), fontWeight: FontWeight.bold, fontSize: 13)),
        )
      ],
    );
  }

  Widget _buildRiwayatList() {
    if (_isLoadingRiwayat) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    if (_listRiwayat.isEmpty) {
       // Dummy mock matching UX screenshot for demonstration
       return Column(
         children: [
           _buildRiwayatItem("B", "Siti Rahayu", "Balita • 12.5 kg • 85 cm", "09:15 WIB"),
           _buildRiwayatItem("L", "Mbah Kromo", "Lansia • 58.2 kg • Tensi: 120/80", "08:45 WIB"),
           _buildRiwayatItem("B", "Siti Rahayu", "Balita • 12.5 kg • 85 cm", "09:15 WIB"),
         ]
       );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _listRiwayat.length > 5 ? 5 : _listRiwayat.length,
      itemBuilder: (context, index) {
        final item = _listRiwayat[index];
        bool isBalita = item['kategori'] == 'balita';
        return _buildRiwayatItem(
          isBalita ? "B" : "L", 
          item['nama_warga'] ?? '-', 
          isBalita 
            ? "Balita • ${item['berat_badan']} kg • ${item['tinggi_badan']} cm"
            : "Lansia • ${item['berat_badan']} kg • ${item['tinggi_badan']} cm • Catatan: ${item['hasil']}",
          item['tanggal'] ?? ''
        );
      },
    );
  }

  Widget _buildRiwayatItem(String letter, String nama, String detail, String waktu) {
    bool isB = letter == "B";
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
           Container(
             width: 48, height: 48,
             decoration: BoxDecoration(
               color: isB ? const Color(0xFFFDE4F2) : const Color(0xFFE6F2FF),
               borderRadius: BorderRadius.circular(12),
             ),
             child: Center(
               child: Text(
                 letter,
                 style: TextStyle(
                   color: isB ? Colors.pinkAccent : Colors.blueAccent,
                   fontSize: 18, fontWeight: FontWeight.w900
                 ),
               ),
             ),
           ),
           const SizedBox(width: 15),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                 const SizedBox(height: 3),
                 Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.normal), maxLines: 1, overflow: TextOverflow.ellipsis),
               ],
             ),
           ),
           Text(
             waktu,
             style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
           ),
        ],
      )
    );
  }
}

// Chart painter for Trend Graph
class _TrendChartPainter extends CustomPainter {
  final List<double> values;
  _TrendChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = const Color(0xFF00A896)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF00A896)
      ..style = PaintingStyle.fill;
      
    final Paint dotInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double minVal = values.reduce((a, b) => a < b ? a : b) - 0.5;
    double maxVal = values.reduce((a, b) => a > b ? a : b) + 0.5;
    double range = maxVal - minVal;
    if (range <= 0) range = 1;

    Path path = Path();
    Path fillPath = Path();

    double xStep = size.width / (values.length - 1);

    List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
        double x = i * xStep;
        double y = size.height - ((values[i] - minVal) / range) * size.height;
        points.add(Offset(x, y));
    }

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
        double y = size.height - (i * (size.height / 4));
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      fillPath.moveTo(points[0].dx, size.height);
      fillPath.lineTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
         double prevX = points[i-1].dx;
         double prevY = points[i-1].dy;
         double curX = points[i].dx;
         double curY = points[i].dy;
         
         double controlX1 = prevX + (curX - prevX) / 2;
         double controlY1 = prevY;
         double controlX2 = prevX + (curX - prevX) / 2;
         double controlY2 = curY;
         
         path.cubicTo(controlX1, controlY1, controlX2, controlY2, curX, curY);
         fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, curX, curY);
      }
      
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      final Paint fillShaderPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF00A896).withValues(alpha: 0.2), Colors.transparent]
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
        
      canvas.drawPath(fillPath, fillShaderPaint);
      canvas.drawPath(path, linePaint);

      for (var p in points) {
         canvas.drawCircle(p, 3.5, dotPaint);
         canvas.drawCircle(p, 1.5, dotInnerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

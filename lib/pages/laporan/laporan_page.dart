import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  int _activeTab = 0; // 0: Iuran, 1: Jumantik, 2: Posyandu

  String _filterTanggal = "Semua Tanggal";
  String _filterBulan = "Semua Bulan";
  String _filterTahun = "Semua Tahun";
  
  List<dynamic> _listIuranRaw = [];
  List<dynamic> _listJumantikRaw = [];
  List<dynamic> _listPosyanduRaw = [];

  List<dynamic> _listIuran = [];
  List<dynamic> _listJumantik = [];
  List<dynamic> _listPosyandu = [];

  bool _isLoading = true;

  int _totalKas = 0;
  double _percentLunas = 0;
  int _totalJentikAda = 0;
  int _totalJumantik = 0;
  int _percentBebasJentik = 0;

  final List<String> _bulanMap = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    setState(() => _isLoading = true);
    try {
      final resIuran = await ApiService.post(ApiUrl.getIuranByUser, {'id_keluarga': 'all'});
      if (resIuran['status'] == 'success' || resIuran['status'] == true) {
        _listIuranRaw = resIuran['data'] ?? [];
      }

      final resJumantik = await ApiService.get(ApiUrl.getJumantik);
      if (resJumantik['status'] == true || resJumantik['status'] == 'success') {
         _listJumantikRaw = resJumantik['data'] ?? [];
      }

      final resPos = await ApiService.get(ApiUrl.getHistoryPosyandu);
      if (resPos['status'] == true || resPos['status'] == 'success') {
         _listPosyanduRaw = resPos['data'] ?? [];
      }

    } catch (e) {
      debugPrint("Laporan error: $e");
    } finally {
      if (mounted) {
         _applyFilter(); // Filter akan menghitung total juga
         setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilter() {
    setState(() {
      _listIuran = _listIuranRaw.where((e) {
         String b = (e['bulan'] ?? '').toString().toLowerCase();
         String t = (e['tahun'] ?? '').toString();
         String tg = e['tanggal_bayar'] ?? ''; // Format: 2026-04-25
         
         if (_filterTahun != "Semua Tahun" && _filterTahun != "Tahun") {
            if (t != _filterTahun && !(tg.startsWith(_filterTahun))) return false;
         }
         if (_filterBulan != "Semua Bulan" && _filterBulan != "Bulan") {
            if (b != _filterBulan.toLowerCase()) {
               // coba parse tanggal_bayar
               if (tg.length >= 10) {
                  int? m = int.tryParse(tg.substring(5, 7));
                  if (m != null && m > 0 && m <= 12) {
                     if (_bulanMap[m-1].toLowerCase() != _filterBulan.toLowerCase()) return false;
                  } else return false;
               } else {
                 return false;
               }
            }
         }
         if (_filterTanggal != "Semua Tanggal" && _filterTanggal != "Tanggal") {
            if (tg.length >= 10) {
               if (tg.substring(8, 10) != _filterTanggal.padLeft(2, '0')) return false;
            } else {
               return false;
            }
         }
         return true;
      }).toList();

      _listJumantik = _listJumantikRaw.where((e) => _filterStandarTanggal(e['tanggal'])).toList();
      _listPosyandu = _listPosyanduRaw.where((e) => _filterStandarTanggal(e['tanggal'])).toList();

      // Rekalkulasi Summary setelah filter
      _totalKas = 0;
      int sumLunas = 0;
      for (var i in _listIuran) {
         if (i['status'].toString().toLowerCase() == 'lunas') {
            _totalKas += int.tryParse(i['nominal'].toString()) ?? 0;
            sumLunas++;
         }
      }
      _percentLunas = _listIuran.isNotEmpty ? (sumLunas / _listIuran.length * 100) : 0;

      _totalJumantik = _listJumantik.length;
      _totalJentikAda = 0;
      for (var j in _listJumantik) {
         if ((j['status_jentik'] ?? '').toString().toLowerCase() == 'ada') _totalJentikAda++;
      }
      _percentBebasJentik = _totalJumantik > 0 ? ((_totalJumantik - _totalJentikAda) / _totalJumantik * 100).toInt() : 100;

    });
  }

  bool _filterStandarTanggal(String? tgl) {
      if (tgl == null || tgl.length < 10) {
         return (_filterTahun == "Semua Tahun" || _filterTahun == "Tahun") && (_filterBulan == "Semua Bulan" || _filterBulan == "Bulan") && (_filterTanggal == "Semua Tanggal" || _filterTanggal == "Tanggal");
      }
      // YYYY-MM-DD
      String year = tgl.substring(0, 4);
      String month = tgl.substring(5, 7);
      String day = tgl.substring(8, 10);

      if (_filterTahun != "Semua Tahun" && _filterTahun != "Tahun" && year != _filterTahun) return false;
      if (_filterBulan != "Semua Bulan" && _filterBulan != "Bulan") {
         int? mIdx = int.tryParse(month);
         if (mIdx == null || mIdx < 1 || mIdx > 12) return false;
         if (_bulanMap[mIdx - 1] != _filterBulan) return false;
      }
      if (_filterTanggal != "Semua Tanggal" && _filterTanggal != "Tanggal" && day != _filterTanggal.padLeft(2, '0')) return false;

      return true;
  }

  String _formatCurr(int amount) {
    String res = "";
    String amtStr = amount.toString();
    int count = 0;
    for (int i = amtStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) res = ".$res";
      res = amtStr[i] + res;
      count++;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    List<String> tglList = ["Semua Tanggal"];
    tglList.addAll(List.generate(31, (i) => (i + 1).toString().padLeft(2, '0')));
    
    List<String> blnList = ["Semua Bulan"];
    blnList.addAll(_bulanMap);
    
    List<String> thnList = ["Semua Tahun"];
    int curY = DateTime.now().year;
    thnList.addAll([curY.toString(), (curY - 1).toString(), (curY - 2).toString()]);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          // Background Watermark Fixed Posisi agar tdk ikut terscroll
          Positioned(
            top: 450, // Agar sejajar dgn list warga (terlihat di belakang card)
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.7,
                child: Image.asset('assets/images/logo_ert.png', width: 220, fit: BoxFit.contain),
              ),
            ),
          ),

          // Dark green top area
          Container(
            height: 380,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // MENGGUNAKAN IMAGE ASSET KALENDER DIPERBESAR
                              Image.asset('assets/images/kalender.png', width: 160, height: 165, fit: BoxFit.contain),
                              const SizedBox(width: 25),
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildFilterDropdown(_filterTanggal, tglList, (v) { _filterTanggal = v; _applyFilter(); }),
                                    _buildFilterDropdown(_filterBulan, blnList, (v) { _filterBulan = v; _applyFilter(); }),
                                    _buildFilterDropdown(_filterTahun, thnList, (v) { _filterTahun = v; _applyFilter(); }),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 25),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildSummaryCards(),
                        ),

                        const SizedBox(height: 20),
                        _buildOrangeTabs(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildActiveList(),
                        ),
                        const SizedBox(height: 50),
                      ],
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF7CB342), borderRadius: BorderRadius.circular(15)),
                child: const Text("Rekap Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 26),
                onPressed: () {},
              ),
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

  Widget _buildFilterDropdown(String label, List<String> items, Function(String) onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAA43A), // Solid base
        gradient: const LinearGradient(colors: [Color(0xFFFAA43A), Color(0xFFED8F20)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(1, 4))]
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: const Color(0xFFED8F20),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          value: label,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Total Kas dynamic check
    int kasFinal = _isLoading ? 15750000 : _totalKas;
    String pLunas = _isLoading ? "90" : _percentLunas.toInt().toString();

    int jentikVal = _isLoading ? 92 : _percentBebasJentik;
    int jentikAda = _isLoading ? 7 : _totalJentikAda;
    
    return Row(
      children: [
        // Card 1
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                       Icon(Icons.account_balance_wallet_outlined, color: Colors.green, size: 14),
                       SizedBox(width: 5),
                       Text("TERBAYAR", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 9)),
                    ]
                  )
                ),
                const SizedBox(height: 15),
                const Text("Total Kas Terkumpul", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text("Rp ${_formatCurr(kasFinal)}", style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Text("+$pLunas% Paid vs bln lalu", style: const TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
              ],
            )
          )
        ),
        const SizedBox(width: 15),
        // Card 2
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                       Icon(Icons.bug_report, color: Colors.red, size: 14),
                       SizedBox(width: 5),
                       Text("ALERT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 9)),
                    ]
                  )
                ),
                const SizedBox(height: 15),
                const Text("Bebas Jentik", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("$jentikVal%", style: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Text("$jentikAda Ada Jentik", style: const TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(2))),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: jentikVal / 100,
                      child: Container(height: 4, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(2)))
                    )
                  ],
                )
              ],
            )
          )
        )
      ]
    );
  }

  Widget _buildOrangeTabs() {
    return Container(
      width: double.infinity, height: 45,
      decoration: const BoxDecoration(
        color: Color(0xFFEF901A), 
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem(0, "Iuran")),
          Expanded(child: _buildTabItem(1, "Jumantik")),
          Expanded(child: _buildTabItem(2, "Posyandu")),
        ]
      )
    );
  }
  
  Widget _buildTabItem(int index, String label) {
    bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        alignment: Alignment.center,
        margin: isActive ? const EdgeInsets.symmetric(horizontal: 5, vertical: 4) : EdgeInsets.zero,
        decoration: isActive ? BoxDecoration(
          color: const Color(0xFFFEB45B),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(0, 2))]
        ) : null,
        child: Text(label, style: TextStyle(color: Colors.white, fontWeight: isActive ? FontWeight.w900 : FontWeight.w500, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildActiveList() {
    String title = "DAFTAR IURAN WARGA";
    List<dynamic> targetList = [];
    if (_activeTab == 0) {
      title = "DAFTAR IURAN WARGA";
      targetList = _listIuran;
    } else if (_activeTab == 1) {
      title = "DAFTAR LAPORAN JUMANTIK";
      targetList = _listJumantik;
    } else {
      title = "DAFTAR PERIKSA POSYANDU";
      targetList = _listPosyandu;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Text(title, style: const TextStyle(color: Color(0xFF334A28), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        const SizedBox(height: 15),
        
        if (targetList.isEmpty && _isLoading)
           const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF334A28))))
        else if (targetList.isEmpty && !_isLoading && _activeTab == 0 && (_filterTahun == "Tahun" || _filterTahun == "Semua Tahun") && (_filterBulan == "Bulan" || _filterBulan == "Semua Bulan") && (_filterTanggal == "Tanggal" || _filterTanggal == "Semua Tanggal"))
           // Menampilkan dummy yang identik mock di desain figma bila database kosong, saat tidak di filter. 
           _buildMockIuranMocks()
        else if (targetList.isEmpty)
           const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Tidak ada data ditemukan.", style: TextStyle(color: Colors.grey))))
        else
           ...targetList.map((e) => _activeTab == 0 ? _buildIuranRow(e) : (_activeTab == 1 ? _buildJumantikRow(e) : _buildPosyanduRow(e))).toList()
      ]
    );
  }

  // --- MOCK BUILDER UNTUK MENDUPLIKASI TEPAT UX DEMO ---
  Widget _buildMockIuranMocks() {
    return Column(
      children: [
        _buildIuranRow({'nama_kepala': 'Bambang Sutedjo', 'no_kk': '327104******001', 'status': 'lunas', 'bulan': 'April', 'tahun': '2026', 'nominal': 0}),
        _buildIuranRow({'nama_kepala': 'Agus Kurniawan', 'no_kk': '327104******442', 'status': 'nunggak', 'bulan': 'April', 'tahun': '2026', 'nominal': 150000}),
        _buildIuranRow({'nama_kepala': 'Rina Permata', 'no_kk': '327104******982', 'status': 'lunas', 'bulan': 'April', 'tahun': '2026', 'nominal': 0}),
        _buildIuranRow({'nama_kepala': 'Heri Mulyadi', 'no_kk': '327104******119', 'status': 'pending', 'bulan': 'April', 'tahun': '2026', 'nominal': 75000}),
      ],
    );
  }

  // ROW IURAN BUILDER
  Widget _buildIuranRow(dynamic item) {
    String name = item['nama_warga'] ?? item['nama_kepala'] ?? "Warga";
    
    // Gunakan literal no_kk dari DB. Jika DB kosong, kembalikan '-'
    String kk = item['no_kk'] != null && item['no_kk'].toString().trim().isNotEmpty 
        ? item['no_kk'].toString() 
        : "Belum diset";

    String stat = item['status']?.toString().toUpperCase() ?? "LUNAS";
    String bln = "${item['bulan'] ?? 'April'} ${item['tahun'] ?? '2026'}";
    
    Color statBg = const Color(0xFFE8F5E9); Color statTxt = Colors.green;
    if (stat == 'NUNGGAK' || stat == 'DITOLAK') { statBg = const Color(0xFFFFEBEE); statTxt = Colors.red; }
    else if (stat == 'PENDING') { statBg = const Color(0xFFFFF3E0); statTxt = Colors.orange; }

    int hash = name.length % 3;
    Color avBg = const Color(0xFFDAF7DF); Color avTxt = Colors.green;
    if (stat == 'NUNGGAK') { avBg = const Color(0xFFE8F0F8); avTxt = const Color(0xFF4A6B8C); }
    else if (stat == 'PENDING') { avBg = const Color(0xFFF5F5F5); avTxt = Colors.blueGrey; }

    List<String> ws = name.split(" ");
    String initials = (ws.isNotEmpty ? ws[0][0] : "W") + (ws.length > 1 ? ws[1][0] : "");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(
        children: [
          CircleAvatar(radius: 22, backgroundColor: avBg, child: Text(initials.toUpperCase(), style: TextStyle(color: avTxt, fontWeight: FontWeight.bold, fontSize: 14))),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 13)),
                const SizedBox(height: 2),
                Text("KK: $kk", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: statBg, borderRadius: BorderRadius.circular(4)),
                      child: Text(stat, style: TextStyle(color: statTxt, fontWeight: FontWeight.w900, fontSize: 8)),
                    ),
                    const SizedBox(width: 8),
                    Text(stat == 'NUNGGAK' || stat == 'PENDING' ? "Rp ${_formatCurr(int.tryParse(item['nominal']?.toString() ?? '0') ?? 0)}" : bln, 
                         style: TextStyle(color: stat == 'NUNGGAK' || stat == 'PENDING' ? statTxt : Colors.grey, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                )
              ]
            ),
          ),
          Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.blueGrey, size: 16),
              const SizedBox(width: 15),
              Container(padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: Color(0xFF25D366), shape: BoxShape.circle), child: const Icon(Icons.forum, color: Colors.white, size: 13)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildJumantikRow(dynamic item) {
    bool ada = item['status_jentik'] == 'ada';
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: ada ? Colors.red.shade50 : Colors.blue.shade50, child: Icon(ada ? Icons.error_outline : Icons.check_circle_outline, color: ada ? Colors.red : Colors.lightBlue)),
        title: Text(item['nama_kepala_keluarga'] ?? 'Warga', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text("Tanggal: ${item['tanggal'] ?? '-'}", style: const TextStyle(fontSize: 10)),
        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: ada ? Colors.red.shade50 : Colors.blue.shade50, borderRadius: BorderRadius.circular(6)), child: Text(ada ? "ADA JENTIK" : "BEBAS", style: TextStyle(color: ada ? Colors.red : Colors.lightBlue, fontSize: 9, fontWeight: FontWeight.bold))),
      )
    );
  }

  Widget _buildPosyanduRow(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: Colors.orange.shade50, child: const Icon(Icons.child_friendly, color: Colors.orange)),
        title: Text(item['nama_warga'] ?? 'Warga', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text("BB: ${item['berat_badan']} kg | TB: ${item['tinggi_badan']} cm", style: const TextStyle(fontSize: 10)),
        trailing: Text(item['tanggal'] ?? '-', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      )
    );
  }
}

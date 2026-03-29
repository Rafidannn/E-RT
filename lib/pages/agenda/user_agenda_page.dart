import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/constants/api_url.dart';

class UserAgendaPage extends StatefulWidget {
  const UserAgendaPage({super.key});
  @override
  State<UserAgendaPage> createState() => _UserAgendaPageState();
}

class _UserAgendaPageState extends State<UserAgendaPage> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  String _errorMsg = '';
  List<dynamic> _agenda = [];
  Map<String, dynamic>? _upcoming;
  String _countdown = '';
  Timer? _timer;

  // Scroll controller untuk date picker — auto-scroll ke hari ini
  final ScrollController _dateScrollCtrl = ScrollController();

  // Kita generate 30 hari dari -7 hari ke depan
  late final List<DateTime> _days;
  late final int _todayIndex;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = List.generate(30, (i) => today.subtract(const Duration(days: 7)).add(Duration(days: i)));
    _todayIndex = _days.indexWhere((d) => d.year == today.year && d.month == today.month && d.day == today.day);
    initializeDateFormatting('id_ID', null).then((_) {
      _fetchAgenda();
      // Scroll ke hari ini setelah frame pertama
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_dateScrollCtrl.hasClients) {
          _dateScrollCtrl.animateTo(
            _todayIndex * 60.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _dateScrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAgenda() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    final tanggal = DateFormat('yyyy-MM-dd').format(_selectedDate);
    try {
      final res = await http.get(Uri.parse('${ApiUrl.getAgenda}?tanggal=$tanggal'));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          _agenda   = data['data']     ?? [];
          _upcoming = data['upcoming'];
          _isLoading = false;
        });
        _startCountdown();
      } else {
        setState(() { _errorMsg = data['message'] ?? 'Error'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMsg = 'Koneksi gagal: $e'; _isLoading = false; });
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    if (_upcoming == null) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final tgl = _upcoming!['tanggal'] ?? '';
      final wkt = _upcoming!['waktu']   ?? '';
      if (tgl.isEmpty || wkt.isEmpty) return;
      try {
        final target = DateTime.parse('$tgl $wkt');
        final diff   = target.difference(DateTime.now());
        if (diff.isNegative) {
          setState(() => _countdown = 'SEDANG BERLANGSUNG');
        } else if (diff.inHours > 0) {
          setState(() => _countdown = 'DIMULAI DALAM ${diff.inHours} JAM');
        } else if (diff.inMinutes > 0) {
          setState(() => _countdown = 'DIMULAI DALAM ${diff.inMinutes} MENIT');
        } else {
          setState(() => _countdown = 'DIMULAI DALAM ${diff.inSeconds} DETIK');
        }
      } catch (_) {}
    });
  }

  Color _catColor(String? cat) {
    switch ((cat ?? '').toLowerCase()) {
      case 'sosial':    return const Color(0xFF27AE60);
      case 'kesehatan': return const Color(0xFF2980B9);
      case 'keamanan':  return const Color(0xFFE74C3C);
      case 'keuangan':  return const Color(0xFFF39C12);
      case 'umum':      return const Color(0xFF7F8C8D);
      default:          return const Color(0xFF8E44AD);
    }
  }

  static const _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Column(
        children: [
          // ── TOP DARK GREEN AREA ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0C2B14),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 12),
                  _buildDateStrip(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── BODY ─────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C2B14)))
              : _errorMsg.isNotEmpty
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_errorMsg, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                  ))
                : Stack(
                    children: [
                      // LOGO WATERMARK GEDE DI BELAKANG
                      Positioned(
                        top: 60, left: 0, right: 0,
                        child: Opacity(
                          opacity: 0.06,
                          child: Center(
                            child: Image.asset(
                              'assets/images/logo_ert.png',
                              height: 320,
                              fit: BoxFit.contain,
                              errorBuilder: (c, e, s) => const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                      _buildScrollBody(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white30, width: 1.5),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          // Title pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF8CAF5D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Agenda RT',
              style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const Spacer(),
          // Icon right
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 1.5),
            ),
            child: const Icon(Icons.share_outlined, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  // ── DATE STRIP ───────────────────────────────────────────────────────────
  Widget _buildDateStrip() {
    return SizedBox(
      height: 66,
      child: ListView.builder(
        controller: _dateScrollCtrl,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (_, i) {
          final d = _days[i];
          final isSel = d.year == _selectedDate.year && d.month == _selectedDate.month && d.day == _selectedDate.day;
          final dotDayIdx = (d.weekday - 1) % 7;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = d);
              _fetchAgenda();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: isSel ? const Color(0xFF8CAF5D) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_dayNames[dotDayIdx],
                    style: TextStyle(
                      color: isSel ? const Color(0xFF0C2B14) : Colors.white60,
                      fontSize: 11, fontWeight: FontWeight.w600,
                    )),
                  const SizedBox(height: 4),
                  Text('${d.day}',
                    style: TextStyle(
                      color: isSel ? const Color(0xFF0C2B14) : Colors.white,
                      fontSize: 18, fontWeight: FontWeight.w900,
                    )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SCROLL BODY ───────────────────────────────────────────────────────────
  Widget _buildScrollBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Featured upcoming card
          if (_upcoming != null) ...[
            _buildFeaturedCard(),
            const SizedBox(height: 24),
          ],

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Jadwal Hari Ini',
                  style: TextStyle(color: Color(0xFF1A1A1A), fontSize: 16, fontWeight: FontWeight.w900)),
                Text('Lihat Semua',
                  style: const TextStyle(color: Color(0xFF27AE60), fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 5),

          // Watermark-ish sub-label
          _buildWatermarkRow(),

          const SizedBox(height: 10),

          if (_agenda.isEmpty)
            _buildEmpty()
          else
            _buildTimeline(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── FEATURED CARD ─────────────────────────────────────────────────────────
  Widget _buildFeaturedCard() {
    final judul  = _upcoming!['judul']  ?? '';
    final waktu  = _upcoming!['waktu']  ?? '';
    final lokasi = _upcoming!['lokasi'] ?? '';
    final foto   = (_upcoming!['foto']  ?? '').toString();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 170,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C5F2E), Color(0xFF8CAF5D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: foto.isNotEmpty
          ? DecorationImage(
              image: NetworkImage('${ApiUrl.baseUrl}/uploads/$foto'),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Color(0xBB0C2B14), BlendMode.darken),
            )
          : null,
        boxShadow: [
          BoxShadow(color: const Color(0xFF2C5F2E).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          // Dekorasi logo RT (watermark)
          Positioned(
            right: -10, bottom: -10,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/logo_ert.png',
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_countdown.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF39C12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_countdown,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                      )
                    else const SizedBox(),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 16),
                    ),
                  ],
                ),
                const Spacer(),
                Text(judul,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                if (waktu.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white70, size: 13),
                    const SizedBox(width: 5),
                    Text('${waktu.length >= 5 ? waktu.substring(0, 5) : waktu} WIB',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                if (lokasi.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, color: Colors.white70, size: 13),
                    const SizedBox(width: 5),
                    Text(lokasi, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── WATERMARK ROW ─────────────────────────────────────────────────────────
  Widget _buildWatermarkRow() {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Opacity(
              opacity: 0.12,
              child: Image.asset(
                'assets/images/logo_ert.png',
                height: 55,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    final formatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Center(
        child: Column(children: [
          Icon(Icons.event_busy_rounded, color: Colors.grey.shade300, size: 70),
          const SizedBox(height: 14),
          Text('Tidak ada jadwal kegiatan\nuntuk $formatted',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13, height: 1.5)),
        ]),
      ),
    );
  }

  // ── TIMELINE ─────────────────────────────────────────────────────────────
  Widget _buildTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(_agenda.length, (index) {
          final item    = _agenda[index];
          final isLast  = index == _agenda.length - 1;
          final waktu   = (item['waktu'] ?? '').toString();
          final timeTxt = waktu.length >= 5 ? waktu.substring(0, 5) : waktu;
          final cat     = (item['kategori'] ?? '').toString();
          final color   = _catColor(cat);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Waktu ──
                SizedBox(
                  width: 46,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(timeTxt,
                      style: const TextStyle(
                        color: Color(0xFF8A9BAB),
                        fontSize: 11, fontWeight: FontWeight.w700,
                      )),
                  ),
                ),

                // ── Dot + Line ──
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: 9, height: 9,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 1.5, color: Colors.grey.shade200),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // ── Card ──
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showDetail(Map<String, dynamic>.from(item)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border(left: BorderSide(color: color, width: 3)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 13, 13, 13),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title + badge
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(item['judul'] ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontSize: 13, fontWeight: FontWeight.w900,
                                    )),
                                ),
                                const SizedBox(width: 8),
                                if (cat.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(cat,
                                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Deskripsi
                            if ((item['isi'] ?? '').toString().isNotEmpty)
                              Text(item['isi'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11, height: 1.4)),
                            const SizedBox(height: 7),
                            // Lokasi + bell
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if ((item['lokasi'] ?? '').toString().isNotEmpty)
                                  Row(children: [
                                    const Icon(Icons.location_on_outlined, color: Color(0xFF8A9BAB), size: 11),
                                    const SizedBox(width: 3),
                                    Text(item['lokasi'],
                                      style: const TextStyle(color: Color(0xFF8A9BAB), fontSize: 10)),
                                  ])
                                else
                                  const SizedBox(),
                                Icon(Icons.notifications_outlined,
                                  color: Colors.grey.shade300, size: 14),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── DETAIL BOTTOM SHEET ───────────────────────────────────────────────────
  void _showDetail(Map<String, dynamic> item) {
    final color = _catColor(item['kategori']);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            controller: ctrl,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(
                  width: 38, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                )),
                const SizedBox(height: 20),
                if ((item['kategori'] ?? '').toString().isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(item['kategori'],
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                const SizedBox(height: 12),
                Text(item['judul'] ?? '',
                  style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 20, fontWeight: FontWeight.w900, height: 1.3)),
                const SizedBox(height: 16),
                if ((item['waktu'] ?? '').toString().isNotEmpty)
                  _dtRow(Icons.access_time_rounded, '${item['waktu'].toString().substring(0, 5)} WIB', color),
                if ((item['lokasi'] ?? '').toString().isNotEmpty)
                  _dtRow(Icons.location_on_outlined, item['lokasi'], color),
                if ((item['pembuat'] ?? '').toString().isNotEmpty)
                  _dtRow(Icons.person_outline, 'Oleh: ${item['pembuat']}', color),
                const SizedBox(height: 16),
                const Divider(color: Colors.black12),
                const SizedBox(height: 12),
                Text(item['isi'] ?? '',
                  style: const TextStyle(color: Color(0xFF444444), fontSize: 13, height: 1.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dtRow(IconData icon, String text, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, color: color, size: 15),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.blueGrey, fontSize: 12))),
    ]),
  );
}

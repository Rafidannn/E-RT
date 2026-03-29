import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../core/constants/api_url.dart';

class UserProfilPage extends StatefulWidget {
  const UserProfilPage({super.key});
  @override
  State<UserProfilPage> createState() => _UserProfilPageState();
}

class _UserProfilPageState extends State<UserProfilPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  Map<String, dynamic>? _profil;
  Map<String, dynamic>? _stats;
  String _iuranStatus = 'belum';

  @override
  void initState() {
    super.initState();
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    setState(() { _isLoading = true; _errorMsg = ''; });
    final prefs = await SharedPreferences.getInstance();
    final nik   = prefs.getString('nik_user') ?? '';
    try {
      final res  = await http.get(Uri.parse('${ApiUrl.getProfilLengkap}?nik=$nik'));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        setState(() {
          _profil      = data['profil'];
          _stats       = data['stats'];
          _iuranStatus = data['iuran_bulan_ini'] ?? 'belum';
          _isLoading   = false;
        });
      } else {
        setState(() { _errorMsg = data['message'] ?? 'Gagal memuat profil'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _errorMsg = 'Koneksi gagal: $e'; _isLoading = false; });
    }
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p.isNotEmpty ? p[0][0].toUpperCase() : '?';
  }

  String _genderText(String? g)  => g == 'L' ? 'Laki-laki' : 'Perempuan';
  String _statusKawinText(String? s) {
    switch (s) {
      case 'kawin':        return 'Menikah';
      case 'belum_kawin':  return 'Belum Menikah';
      case 'cerai_hidup':  return 'Cerai Hidup';
      case 'cerai_mati':   return 'Cerai Mati';
      default:             return s ?? '-';
    }
  }
  String _kesehatanText(String? s) {
    switch (s) {
      case 'umum':        return 'Umum';
      case 'bumil':       return 'Ibu Hamil';
      case 'lansia':      return 'Lansia';
      case 'disabilitas': return 'Disabilitas';
      default:            return s ?? '-';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Column(
        children: [
          // ── HEADER ──────────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0C2B14),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
            ),
            child: SafeArea(
              bottom: false,
              child: _buildAppBar(),
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C2B14)))
              : _errorMsg.isNotEmpty
                ? Center(child: Text(_errorMsg, style: const TextStyle(color: Colors.grey)))
                : Stack(
                    children: [
                      // Logo watermark
                      Positioned(
                        top: 40, left: 0, right: 0,
                        child: Opacity(
                          opacity: 0.06,
                          child: Center(
                            child: Image.asset('assets/images/logo_ert.png', height: 300,
                              errorBuilder: (c, e, s) => const SizedBox()),
                          ),
                        ),
                      ),
                      _buildBody(),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 1.5)),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(20)),
            child: const Text('Profil Saya', style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _fetchProfil,
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 1.5)),
              child: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final nama       = _profil?['nama']       ?? '-';
    final nik        = _profil?['nik']        ?? '-';
    final role       = _profil?['role']       ?? 'warga';
    final verified   = (_profil?['is_verified'] ?? 0) == 1;
    final bergabung  = _profil?['bergabung_sejak'] ?? '';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 24),

          // ── Avatar Card ───────────────────────────────────────────────
          _buildAvatarCard(nama, nik, role, verified, bergabung),

          const SizedBox(height: 20),

          // ── Stats Row ─────────────────────────────────────────────────
          _buildStatsRow(),

          const SizedBox(height: 20),

          // ── Iuran Status Card ─────────────────────────────────────────
          _buildIuranCard(),

          const SizedBox(height: 20),

          // ── Info Kependudukan ─────────────────────────────────────────
          _buildInfoCard(),

          const SizedBox(height: 20),

          // ── Aksi ─────────────────────────────────────────────────────
          _buildAksiCard(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── AVATAR CARD ───────────────────────────────────────────────────────────
  Widget _buildAvatarCard(String nama, String nik, String role, bool verified, String bergabung) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Avatar circle
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C5F2E), Color(0xFF8CAF5D)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF2C5F2E).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Center(child: Text(_initials(nama),
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))),
          ),
          const SizedBox(height: 14),
          Text(nama, style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(nik, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _chip(role.toUpperCase(), const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
              const SizedBox(width: 8),
              _chip(
                verified ? '✓ TERVERIFIKASI' : '⏳ BELUM VERIFY',
                verified ? const Color(0xFF27AE60) : const Color(0xFFE65100),
                verified ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
              ),
            ],
          ),
          if (bergabung.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('Bergabung sejak ${bergabung.substring(0, 10)}',
              style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color fg, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: fg, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
  );

  // ── STATS ROW ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final laporan = _stats?['total_laporan']   ?? 0;
    final surat   = _stats?['total_surat']     ?? 0;
    final iuran   = _stats?['iuran_lunas']     ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statCol(laporan.toString(), 'Laporan', Icons.campaign_outlined, const Color(0xFF2980B9)),
          Container(height: 40, width: 1, color: Colors.black12),
          _statCol(surat.toString(), 'Surat', Icons.description_outlined, const Color(0xFF8E44AD)),
          Container(height: 40, width: 1, color: Colors.black12),
          _statCol(iuran.toString(), 'Iuran Lunas', Icons.payments_outlined, const Color(0xFF27AE60)),
        ],
      ),
    );
  }

  Widget _statCol(String val, String label, IconData icon, Color color) => Column(
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      Text(val, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600)),
    ],
  );

  // ── IURAN STATUS CARD ─────────────────────────────────────────────────────
  Widget _buildIuranCard() {
    final isLunas  = _iuranStatus == 'lunas';
    final isMenunggu = _iuranStatus == 'menunggu';
    final color    = isLunas ? const Color(0xFF27AE60) : isMenunggu ? const Color(0xFFF39C12) : const Color(0xFFE74C3C);
    final bg       = isLunas ? const Color(0xFFE8F5E9)  : isMenunggu ? const Color(0xFFFFF8E1) : const Color(0xFFFDEDEC);
    final icon     = isLunas ? Icons.check_circle_outline : isMenunggu ? Icons.hourglass_top : Icons.warning_amber_outlined;
    final text     = isLunas ? 'Lunas' : isMenunggu ? 'Menunggu Verifikasi' : 'Belum Dibayar';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STATUS IURAN BULAN INI',
                style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
              const SizedBox(height: 4),
              Text(text, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  // ── INFO KEPENDUDUKAN ─────────────────────────────────────────────────────
  Widget _buildInfoCard() {
    final ttl   = '${_profil?['tempat_lahir'] ?? '-'}, ${_profil?['tanggal_lahir'] ?? '-'}';
    final bpjs  = (_profil?['bpjs_aktif'] ?? 0) == 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.person_outline, color: Color(0xFF27AE60), size: 18),
            const SizedBox(width: 8),
            const Text('Data Kependudukan', style: TextStyle(color: Color(0xFF0C2B14), fontSize: 14, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 16),
          _infoRow(Icons.cake_outlined,         'Tempat/Tgl Lahir',   ttl),
          _infoRow(Icons.person_pin_outlined,   'Jenis Kelamin',       _genderText(_profil?['jenis_kelamin'])),
          _infoRow(Icons.school_outlined,        'Pendidikan',          _profil?['pendidikan'] ?? '-'),
          _infoRow(Icons.work_outline,           'Pekerjaan',           _profil?['pekerjaan'] ?? '-'),
          _infoRow(Icons.favorite_outline,       'Status Perkawinan',   _statusKawinText(_profil?['status_perkawinan'])),
          _infoRow(Icons.health_and_safety_outlined, 'Status Kesehatan', _kesehatanText(_profil?['status_kesehatan_khusus'])),
          const SizedBox(height: 8),
          // BPJS badge
          Row(children: [
            const Icon(Icons.medical_services_outlined, color: Colors.grey, size: 14),
            const SizedBox(width: 8),
            const Text('BPJS', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: bpjs ? const Color(0xFFE8F5E9) : const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                bpjs ? '✓ Aktif' : '✗ Tidak Aktif',
                style: TextStyle(
                  color: bpjs ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                  fontSize: 11, fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 14),
        const SizedBox(width: 8),
        SizedBox(width: 120, child: Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 12))),
        Expanded(child: Text(value, style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 12, fontWeight: FontWeight.w700))),
      ],
    ),
  );

  // ── AKSI CARD ─────────────────────────────────────────────────────────────
  Widget _buildAksiCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        children: [
          _aksiTile(Icons.lock_outline, 'Ganti Password', const Color(0xFF2980B9), () => _showGantiPassword()),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Colors.black12),
          _aksiTile(Icons.logout_rounded, 'Keluar / Logout', const Color(0xFFE74C3C), () => _showLogoutDialog()),
        ],
      ),
    );
  }

  Widget _aksiTile(IconData icon, String label, Color color, VoidCallback onTap) => ListTile(
    onTap: onTap,
    leading: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: color, size: 18),
    ),
    title: Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w700)),
    trailing: Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5)),
  );

  // ── GANTI PASSWORD ────────────────────────────────────────────────────────
  void _showGantiPassword() {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              const Text('Ganti Password', style: TextStyle(color: Color(0xFF0C2B14), fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              _pwField('Password Lama', oldCtrl),
              const SizedBox(height: 12),
              _pwField('Password Baru', newCtrl),
              const SizedBox(height: 12),
              _pwField('Konfirmasi Password Baru', confCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Fitur ganti password sedang dalam pengembangan'),
                      backgroundColor: Color(0xFF2980B9),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C2B14),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Simpan Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pwField(String hint, TextEditingController ctrl) => TextField(
    controller: ctrl,
    obscureText: true,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true, fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
    ),
  );

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.logout_rounded, color: Color(0xFFE74C3C), size: 22),
          SizedBox(width: 10),
          Text('Konfirmasi Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        ]),
        content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?',
          style: TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

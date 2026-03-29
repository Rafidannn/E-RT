import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/constants/api_url.dart';

class UserKeluargaPage extends StatefulWidget {
  const UserKeluargaPage({super.key});
  @override
  State<UserKeluargaPage> createState() => _UserKeluargaPageState();
}

class _UserKeluargaPageState extends State<UserKeluargaPage> {
  bool _isLoading = true;
  String _errorMsg = '';
  Map<String, dynamic>? _keluargaData;
  List<dynamic> _anggotaList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final nik = prefs.getString('nik_user') ?? '';
    try {
      final res = await http.get(Uri.parse('${ApiUrl.getInfoKeluarga}?nik=$nik'));
      final data = json.decode(res.body);
      if (data['status'] == 'success') {
        if (mounted) setState(() {
          _keluargaData = data['keluarga'];
          _anggotaList  = data['anggota'] ?? [];
          _isLoading    = false;
        });
      } else {
        if (mounted) setState(() { _errorMsg = data['message'] ?? 'Error'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorMsg = 'Koneksi gagal: $e'; _isLoading = false; });
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  Color _avatarColor(int i) {
    const colors = [Color(0xFF1B3A5A), Color(0xFF00897B), Color(0xFF5C6BC0), Color(0xFFF57F17), Color(0xFF6A1B9A)];
    return colors[i % colors.length];
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: Column(
        children: [
          // ── TOP DARK GREEN HEADER ──────────────────────────────────────
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

          // ── BODY ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C2B14)))
              : _errorMsg.isNotEmpty
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_errorMsg, textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Row(
        children: [
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF8CAF5D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Info Keluarga',
              style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const Spacer(),
          const SizedBox(width: 38),
        ],
      ),
    );
  }

  // ── BODY ─────────────────────────────────────────────────────────────────
  Widget _buildBody() {
    final noKk    = _keluargaData?['no_kk']            ?? '-';
    final kepala  = _keluargaData?['kepala_keluarga']  ?? '-';
    final alamat  = _keluargaData?['alamat']            ?? '-';
    final rtRw    = _keluargaData?['rt_rw']             ?? '-';
    final ekonomi = _keluargaData?['status_ekonomi']   ?? '-';
    final stats   = _keluargaData?['stats'] as Map? ?? {};
    final anggota = stats['anggota'] ?? 0;
    final bpjs    = stats['bpjs']    ?? 0;
    final lansia  = stats['lansia']  ?? 0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Kartu Identitas Keluarga ──────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF8CAF5D),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8CAF5D).withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Stack(
              children: [
                // Logo watermark pojok kanan bawah
                Positioned(
                  right: -8, bottom: -8,
                  child: Opacity(
                    opacity: 0.12,
                    child: Image.asset(
                      'assets/images/logo_ert.png',
                      width: 120, height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bell icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Detail Keluarga',
                            style: TextStyle(color: Color(0xFF0C2B14), fontSize: 16, fontWeight: FontWeight.w900)),
                          Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                            ),
                            child: const Icon(Icons.notifications_outlined, color: Color(0xFF5C6BC0), size: 17),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Label
                      const Text('NOMOR KK',
                        style: TextStyle(color: Color(0xFF2C6B3F), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(noKk,
                        style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      const SizedBox(height: 20),
                      // Kepala + Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Kepala Keluarga',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4E6D2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(ekonomi,
                              style: const TextStyle(color: Color(0xFF1E3C28), fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Bpk/Ibu. $kepala',
                        style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 14, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 16),
                      // Alamat
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('$alamat, RT $rtRw',
                              style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Stats Strip ───────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(36, 16, 36, 0),
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(anggota.toString(), 'ANGGOTA',   const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                Container(height: 36, width: 1, color: Colors.black12),
                _statItem(bpjs.toString(),   'BPJS AKTIF', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
                Container(height: 36, width: 1, color: Colors.black12),
                _statItem(lansia.toString(), 'LANSIA',     const Color(0xFFFFF3E0), const Color(0xFFE65100)),
              ],
            ),
          ),

          // ── Section Label ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Anggota Keluarga',
                  style: TextStyle(color: Color(0xFF0C2B14), fontSize: 16, fontWeight: FontWeight.w900)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Terverifikasi',
                    style: TextStyle(color: Color(0xFF27AE60), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Logo watermark bawah label
          Padding(
            padding: const EdgeInsets.only(left: 22, bottom: 4),
            child: Row(
              children: [
                Opacity(
                  opacity: 0.12,
                  child: Image.asset('assets/images/logo_ert.png', height: 50, fit: BoxFit.contain),
                ),
              ],
            ),
          ),

          // ── Member Cards ──────────────────────────────────────────────
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _anggotaList.length,
            itemBuilder: (_, i) => _memberCard(_anggotaList[i], i),
          ),

          const SizedBox(height: 20),

          // ── Footer ────────────────────────────────────────────────────
          const Text('SISTEM INFORMASI PELAYANAN RT © 2026',
            style: TextStyle(color: Colors.black26, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ── STAT ITEM ─────────────────────────────────────────────────────────────
  Widget _statItem(String count, String label, Color bg, Color fg) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(child: Text(count,
            style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 6),
        Text(label,
          style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ],
    );
  }

  // ── MEMBER CARD ───────────────────────────────────────────────────────────
  Widget _memberCard(dynamic anggota, int index) {
    final nama    = (anggota['nama']         ?? '').toString();
    final nik     = (anggota['nik']          ?? '').toString();
    final role    = (anggota['role']         ?? '').toString();
    final gender  = (anggota['jk']           ?? 'L').toString();
    final khusus  = (anggota['status_khusus']?? 'umum').toString();

    final genderBg  = gender == 'L' ? const Color(0xFFE3F2FD) : const Color(0xFFFCE4EC);
    final genderTxt = gender == 'L' ? const Color(0xFF1565C0) : const Color(0xFFD81B60);
    final hasKhusus = khusus != 'umum' && khusus.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _avatarColor(index), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(_initials(nama),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama,
                  style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 14, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(nik,
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 10)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: [
                    Text(role.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF27AE60), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    if (hasKhusus)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEDEC),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(khusus.toUpperCase(),
                          style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Gender + chevron
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(color: genderBg, shape: BoxShape.circle),
                child: Center(child: Text(gender,
                  style: TextStyle(color: genderTxt, fontSize: 10, fontWeight: FontWeight.w900))),
              ),
              const SizedBox(height: 8),
              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueGrey, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

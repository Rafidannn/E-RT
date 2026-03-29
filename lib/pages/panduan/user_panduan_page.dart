import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class UserPanduanPage extends StatefulWidget {
  const UserPanduanPage({super.key});
  @override
  State<UserPanduanPage> createState() => _UserPanduanPageState();
}

class _UserPanduanPageState extends State<UserPanduanPage> {
  int _activeTab = 0; // 0 = Panduan, 1 = FAQ, 2 = Kontak

  // ── Data FAQ ──────────────────────────────────────────────────────────────
  final List<Map<String, String>> _faqs = [
    {
      'q': 'Kenapa surat pengantar saya belum disetujui?',
      'a': 'Proses persetujuan surat dilakukan oleh Pengurus RT dan membutuhkan waktu 1–3 hari kerja. Jika sudah lebih dari 3 hari, silakan hubungi langsung Ketua RT.',
    },
    {
      'q': 'Bagaimana jika saya lupa password?',
      'a': 'Hubungi Admin RT untuk melakukan reset password. Admin dapat mengubah password melalui panel administrasi. Pastikan NIK Anda sudah terdaftar di sistem.',
    },
    {
      'q': 'NIK saya tidak terdaftar saat mendaftar, kenapa?',
      'a': 'Data NIK harus didaftarkan terlebih dahulu oleh Admin RT ke dalam database warga. Hubungi Ketua RT atau Sekretaris RT untuk meminta pendaftaran NIK Anda.',
    },
    {
      'q': 'Foto laporan tidak muncul di detail laporan?',
      'a': 'Pastikan HP Anda terhubung ke jaringan WiFi yang sama dengan server RT. Aplikasi ini menggunakan jaringan lokal (LAN), sehingga koneksi internet biasa tidak cukup.',
    },
    {
      'q': 'Iuran sudah dibayar tapi status masih merah?',
      'a': 'Pembayaran iuran perlu diverifikasi terlebih dahulu oleh Admin RT. Proses verifikasi biasanya dilakukan dalam waktu 1x24 jam setelah bukti pembayaran diterima.',
    },
    {
      'q': 'Bagaimana cara mengubah data anggota keluarga?',
      'a': 'Perubahan data keluarga tidak dapat dilakukan langsung di aplikasi. Datang ke sekretariat RT dengan membawa dokumen pendukung (KK, KTP) untuk meminta perubahan data.',
    },
    {
      'q': 'Apakah aplikasi ini bisa diakses dari luar rumah?',
      'a': 'Saat ini aplikasi menggunakan jaringan lokal RT (WiFi/LAN), sehingga hanya bisa diakses ketika berada di jaringan yang sama dengan server RT. Pengembangan akses jarak jauh masih dalam rencana.',
    },
  ];

  // ── Data Guide Steps ──────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _guides = [
    {
      'icon': Icons.payments_outlined,
      'color': const Color(0xFF27AE60),
      'title': 'Bayar Iuran RT',
      'videoAsset': 'assets/video/tutorial_iuran.mp4',
      'steps': [
        'Buka menu "Bayar Iuran" di halaman utama.',
        'Pilih bulan iuran yang ingin dibayar.',
        'Lakukan pembayaran sesuai nominal yang tertera.',
        'Upload bukti pembayaran (foto/screenshot).',
        'Tunggu konfirmasi verifikasi dari Admin RT (1x24 jam).',
      ],
    },
    {
      'icon': Icons.campaign_outlined,
      'color': const Color(0xFF2980B9),
      'title': 'Lapor RT (Aduan)',
      'videoAsset': 'assets/video/tutorial_lapor.mp4',
      'steps': [
        'Buka menu "Lapor RT" di halaman utama.',
        'Tap tombol "Buat Laporan".',
        'Isi Subjek, Kategori, dan Detail laporan.',
        'Lampirkan foto bukti (kamera atau galeri).',
        'Aktifkan GPS untuk mengisi lokasi otomatis, atau isi manual.',
        'Tap "Kirim Laporan" dan tunggu tindak lanjut dari RT.',
      ],
    },
    {
      'icon': Icons.description_outlined,
      'color': const Color(0xFF8E44AD),
      'title': 'Ajukan Surat Pengantar',
      'videoAsset': 'assets/video/tutorial_surat.mp4',
      'steps': [
        'Buka menu "Surat Pengantar" di halaman utama.',
        'Tap tombol "Ajukan Surat Baru".',
        'Pilih jenis surat dan isi keperluan.',
        'Tentukan metode pengambilan: Fisik atau Digital (PDF).',
        'Lampirkan dokumen pendukung jika diperlukan.',
        'Tap "Ajukan Surat" dan pantau statusnya di riwayat.',
      ],
    },
    {
      'icon': Icons.family_restroom_rounded,
      'color': const Color(0xFFF57F17),
      'title': 'Info Keluarga',
      'steps': [
        'Buka menu "Info Keluarga" di halaman utama.',
        'Data keluarga ditampilkan berdasarkan Kartu Keluarga (KK) Anda.',
        'Lihat informasi lengkap setiap anggota keluarga.',
        'Untuk perubahan data, hubungi Pengurus RT secara langsung.',
      ],
    },
  ];

  // Track expand state FAQ
  late List<bool> _faqExpanded;

  @override
  void initState() {
    super.initState();
    _faqExpanded = List.filled(_faqs.length, false);
  }

  // ────────────────────────────────────────────────────────────────────────
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
              child: Column(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 14),
                  _buildTabBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── BODY ────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                // Logo watermark
                Positioned(
                  top: 40, left: 0, right: 0,
                  child: Opacity(
                    opacity: 0.06,
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo_ert.png',
                        height: 300,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const SizedBox(),
                      ),
                    ),
                  ),
                ),
                _buildTabContent(),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
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
            child: const Text('Panduan & FAQ',
              style: TextStyle(color: Color(0xFF0C2B14), fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const Spacer(),
          const SizedBox(width: 38), // Placeholder simetris
        ],
      ),
    );
  }

  // ── TAB BAR ──────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.menu_book_outlined, 'label': 'Panduan'},
      {'icon': Icons.help_outline_rounded, 'label': 'FAQ'},
      {'icon': Icons.phone_outlined, 'label': 'Kontak'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isActive = _activeTab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF8CAF5D) : Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(tabs[i]['icon'] as IconData,
                      color: isActive ? const Color(0xFF0C2B14) : Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(height: 4),
                    Text(tabs[i]['label'] as String,
                      style: TextStyle(
                        color: isActive ? const Color(0xFF0C2B14) : Colors.white54,
                        fontSize: 11, fontWeight: FontWeight.bold,
                      )),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── TAB CONTENT ──────────────────────────────────────────────────────────
  Widget _buildTabContent() {
    switch (_activeTab) {
      case 0: return _buildPanduanTab();
      case 1: return _buildFaqTab();
      case 2: return _buildKontakTab();
      default: return const SizedBox();
    }
  }

  // ── PANDUAN TAB ───────────────────────────────────────────────────────────
  Widget _buildPanduanTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Cara Penggunaan Fitur', Icons.touch_app_rounded),
          const SizedBox(height: 14),
          ..._guides.map((g) => _buildGuideCard(g)).toList(),
        ],
      ),
    );
  }

  Widget _buildGuideCard(Map<String, dynamic> guide) {
    final color      = guide['color'] as Color;
    final steps      = guide['steps'] as List<String>;
    final videoAsset = guide['videoAsset'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(guide['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(guide['title'],
                style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 14, fontWeight: FontWeight.w900)),
            ]),

            // VIDEO PLAYER (jika ada)
            if (videoAsset != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _VideoCard(assetPath: videoAsset, accentColor: color),
              ),
            ],

            const SizedBox(height: 14),
            ...steps.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20, height: 20,
                    margin: const EdgeInsets.only(top: 1),
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${entry.key + 1}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(entry.value,
                      style: const TextStyle(color: Color(0xFF444444), fontSize: 12, height: 1.5)),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  // ── FAQ TAB ───────────────────────────────────────────────────────────────
  Widget _buildFaqTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Pertanyaan yang Sering Ditanyakan', Icons.help_outline_rounded),
          const SizedBox(height: 14),
          ...List.generate(_faqs.length, (i) => _buildFaqCard(i)),
        ],
      ),
    );
  }

  Widget _buildFaqCard(int index) {
    final faq      = _faqs[index];
    final isOpen   = _faqExpanded[index];
    return GestureDetector(
      onTap: () => setState(() => _faqExpanded[index] = !isOpen),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOpen ? const Color(0xFF8CAF5D) : Colors.black.withOpacity(0.05),
            width: isOpen ? 1.5 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: isOpen ? const Color(0xFF8CAF5D) : const Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: Text('Q',
                      style: TextStyle(
                        color: isOpen ? Colors.white : Colors.grey,
                        fontSize: 11, fontWeight: FontWeight.bold,
                      ))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(faq['q']!,
                      style: TextStyle(
                        color: isOpen ? const Color(0xFF0C2B14) : const Color(0xFF333333),
                        fontSize: 12, fontWeight: FontWeight.w700, height: 1.4,
                      )),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                      color: isOpen ? const Color(0xFF8CAF5D) : Colors.grey,
                      size: 20),
                  ),
                ],
              ),
              if (isOpen) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('A', style: TextStyle(color: Color(0xFF27AE60), fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(faq['a']!,
                        style: const TextStyle(color: Color(0xFF444444), fontSize: 12, height: 1.6))),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── KONTAK TAB ────────────────────────────────────────────────────────────
  Widget _buildKontakTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Informasi & Kontak RT', Icons.phone_outlined),
          const SizedBox(height: 14),

          _contactCard(
            icon: Icons.person_outline,
            color: const Color(0xFF27AE60),
            title: 'Ketua RT',
            subtitle: 'Ahmad Subarjo',
            detail: 'Hubungi untuk urusan administrasi & perizinan.',
          ),
          _contactCard(
            icon: Icons.phone_in_talk_outlined,
            color: const Color(0xFF2980B9),
            title: 'Nomor Darurat RT',
            subtitle: '+62 812-XXXX-XXXX',
            detail: 'Tersedia Senin–Jumat, 08.00–17.00 WIB.',
          ),
          _contactCard(
            icon: Icons.home_work_outlined,
            color: const Color(0xFFF39C12),
            title: 'Sekretariat RT',
            subtitle: 'Balai Warga RT 03/RW 12',
            detail: 'Jl. Melati No. 45, Kel. Mekarjaya, Kec. Sukmajaya.',
          ),
          _contactCard(
            icon: Icons.access_time_rounded,
            color: const Color(0xFF8E44AD),
            title: 'Jam Pelayanan',
            subtitle: 'Senin – Sabtu',
            detail: '08.00 – 16.00 WIB. Hari Minggu & Libur Nasional tutup.',
          ),

          const SizedBox(height: 20),
          _sectionHeader('Syarat & Ketentuan', Icons.info_outline_rounded),
          const SizedBox(height: 12),

          ...[
            'Iuran RT dibayar paling lambat tanggal 10 setiap bulan.',
            'Pengajuan surat pengantar harus menyertakan nomor KTP/NIK yang valid.',
            'Laporan aduan wajib menyertakan foto bukti dan lokasi kejadian.',
            'Data keluarga hanya dapat diubah secara langsung di sekretariat RT.',
            'Aplikasi ini hanya untuk digunakan oleh warga yang terdaftar resmi.',
          ].map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Icon(Icons.circle, color: Color(0xFF8CAF5D), size: 7),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(s, style: const TextStyle(color: Color(0xFF555555), fontSize: 12, height: 1.5))),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _contactCard({required IconData icon, required Color color, required String title, required String subtitle, required String detail}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 13, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 11, height: 1.4)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(children: [
      Icon(icon, color: const Color(0xFF27AE60), size: 18),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(color: Color(0xFF0C2B14), fontSize: 15, fontWeight: FontWeight.w900)),
    ]);
  }
}

// ── VIDEO CARD WIDGET ─────────────────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final String assetPath;
  final Color accentColor;
  const _VideoCard({required this.assetPath, required this.accentColor});

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _vpCtrl;
  ChewieController? _chewieCtrl;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      _vpCtrl = VideoPlayerController.asset(widget.assetPath);
      await _vpCtrl!.initialize();
      _chewieCtrl = ChewieController(
        videoPlayerController: _vpCtrl!,
        autoPlay: false,
        looping: false,
        aspectRatio: _vpCtrl!.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.accentColor,
          handleColor: widget.accentColor,
          bufferedColor: widget.accentColor.withOpacity(0.3),
          backgroundColor: Colors.grey.shade300,
        ),
      );
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = true);
    }
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _vpCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        height: 180,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: const Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, color: Colors.grey, size: 36),
            SizedBox(height: 8),
            Text('Video tidak dapat dimuat', style: TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        )),
      );
    }

    if (!_initialized) {
      return Container(
        height: 180,
        decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(12)),
        child: Center(child: CircularProgressIndicator(color: widget.accentColor, strokeWidth: 2)),
      );
    }

    return AspectRatio(
      aspectRatio: _vpCtrl!.value.aspectRatio,
      child: Chewie(controller: _chewieCtrl!),
    );
  }
}

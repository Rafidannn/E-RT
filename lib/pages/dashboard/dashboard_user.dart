import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  List<dynamic> _listPengumuman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPengumuman();
  }

  Future<void> _getPengumuman() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiUrl.pengumuman);

      if (response['status'] == true) {
        setState(() {
          _listPengumuman = response['data'];
        });
      }
    } catch (e) {
      debugPrint("Error Pengumuman: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Pake Stack biar Bottom Navbar bisa melayang di atas konten
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
          : Stack(
        children: [
          RefreshIndicator(
            onRefresh: _getPengumuman,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildStatusCard(),
                        const SizedBox(height: 20),
                        _buildAnnouncementCard(),
                        const SizedBox(height: 20),
                        _buildHistoryCard(),
                        // Kasih space bawah biar konten nggak ketutup Navbar
                        const SizedBox(height: 110),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // INI YANG TADI BIKIN WARNING: Sekarang udah dipanggil!
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavbar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.settings_outlined, color: Colors.white),
          Column(
            children: const [
              Text(
                'Selamat Datang, User',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildStatusItem(Icons.check_circle_outline, "Status iuran: LUNAS", "Rp 50.000 · Januari 2026", Colors.green),
          const Divider(height: 1, indent: 50),
          _buildStatusItem(Icons.attach_money, "Sisa Iuran: Rp 0", "Tidak ada tunggakan", Colors.orange),
          const Divider(height: 1, indent: 50),
          _buildStatusItem(Icons.favorite_border, "Status Kesehatan", "Sehat", Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatusItem(IconData icon, String title, String subtitle, Color color) {
    return ListTile(
      leading: Icon(icon, color: color, size: 30),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildAnnouncementCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active_outlined, color: Colors.orange),
                  SizedBox(width: 10),
                  Text("Pengumuman", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 15),
          if (_listPengumuman.isEmpty)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Belum ada pengumuman", style: TextStyle(color: Colors.grey)),
            ))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _listPengumuman.length > 3 ? 3 : _listPengumuman.length,
              separatorBuilder: (context, index) => const Divider(height: 25),
              itemBuilder: (context, index) {
                final item = _listPengumuman[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item['judul'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item['tanggal'] ?? '',
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item['isi'] ?? '-',
                      style: const TextStyle(color: Colors.black87, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Oleh: ${item['pembuat'] ?? 'Admin'}",
                      style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Text(
        "Riwayat Jumantik Posyandu:",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, "Home", true),
          _buildNavItem(Icons.people_outline, "", false),
          _buildNavItem(Icons.account_balance_wallet_outlined, "", false),
          _buildNavItem(Icons.person_outline, "", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? Colors.white : Colors.white70, size: 28),
        if (label.isNotEmpty)
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
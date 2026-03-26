import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'user_bayar_iuran_page.dart';
import 'user_detail_iuran_page.dart';

class UserRiwayatIuranPage extends StatefulWidget {
  const UserRiwayatIuranPage({super.key});

  @override
  State<UserRiwayatIuranPage> createState() => _UserRiwayatIuranPageState();
}

class _UserRiwayatIuranPageState extends State<UserRiwayatIuranPage> {
  bool _isLoading = true;
  List<dynamic> _historyList = [];
  int _totalTerbayarTahunIni = 0;
  int _bulanLunas = 0;
  int _bulanNunggak = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String nik = prefs.getString('nik_user') ?? '';

      if (nik.isEmpty) {
        throw Exception("NIK tidak ditemukan, silakan login ulang");
      }

      final response = await ApiService.post(ApiUrl.getIuranByUser, {
        'nik': nik,
      });

      if (response['status'] == 'success') {
        List<dynamic> data = response['data'] ?? [];
        _calculateSummary(data);
        setState(() {
          _historyList = data;
        });
      } else {
        throw Exception(response['message'] ?? 'Gagal memuat data');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calculateSummary(List<dynamic> data) {
    int totalPaid = 0;
    int lunasCount = 0;
    int nunggakCount = 0;

    for (var item in data) {
      int nominal = int.tryParse(item['nominal'].toString()) ?? 0;
      String status = item['status']?.toString().toLowerCase() ?? '';

      if (status == 'lunas' || status == 'pending') {
        totalPaid += nominal;
        if (status == 'lunas') lunasCount++;
      }

      if (status == 'belum' || status == 'ditolak') {
        nunggakCount++;
      }
    }

    _totalTerbayarTahunIni = totalPaid;
    _bulanLunas = lunasCount;
    _bulanNunggak = nunggakCount;
  }

  String _formatCurrency(int amount) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatCurrency.format(amount);
  }

  String _getCurrentDate() {
    return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7EF), // Light beige background
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          _buildBackgroundShape(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDateCard(),
                const SizedBox(height: 20),
                _buildSummaryCard(),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildHistoryList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          bool? refresh = await Navigator.push(context, MaterialPageRoute(builder: (context) => const UserBayarIuranPage()));
          if (refresh == true) {
            _fetchData();
          }
        },
        backgroundColor: const Color(0xFF0C2B10), // Dark green color matching header
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
            "Bayar Iuran",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'RobotoMedium')
        ),
      ),
    );
  }

  Widget _buildBackgroundShape() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0C2B10), // Dark Green
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 1.5),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  iconSize: 20,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: EdgeInsets.zero,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B9B49), // Lighter green pill
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Riwayat Iuran',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RobotoMedium',
                    fontSize: 16,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                onPressed: () {},
                iconSize: 28,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white30, thickness: 1),
        ],
      ),
    );
  }

  Widget _buildDateCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE99625), // Orange color
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getCurrentDate(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'RobotoMedium',
              ),
            ),
            const Icon(Icons.calendar_month_outlined, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Keseluruhan Tagihan',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'RobotoMedium',
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatCurrency(_totalTerbayarTahunIni),
              style: const TextStyle(
                color: Color(0xFF1B232E),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoBlack',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 8),
                const SizedBox(width: 8),
                Text(
                  '$_bulanLunas BULAN LUNAS / $_bulanNunggak NUNGGAK',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_historyList.isEmpty) {
      return const Center(child: Text('Belum ada riwayat iuran.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      itemCount: _historyList.length,
      itemBuilder: (context, index) {
        final item = _historyList[index];
        return _buildHistoryCard(item);
      },
    );
  }

  Widget _buildHistoryCard(dynamic item) {
    String jenisIuran = item['jenis_iuran'] ?? 'Iuran';
    String bulan = item['bulan'] ?? '';
    String tahun = item['tahun']?.toString() ?? '';
    int nominal = int.tryParse(item['nominal'].toString()) ?? 0;
    String status = item['status']?.toString().toUpperCase() ?? 'BELUM';
    String tanggalBayar = item['tanggal_bayar'] ?? '';

    // Convert date format if needed, simplistic approach:
    String displayDate = 'Belum dibayar';
    if (tanggalBayar.isNotEmpty && tanggalBayar != 'null') {
      try {
        DateTime parsed = DateTime.parse(tanggalBayar);
        displayDate = 'Dibayar pada ${DateFormat('dd MMMM', 'id_ID').format(parsed)}';
      } catch (e) {
        displayDate = 'Dibayar pada $tanggalBayar';
      }
    }

    // Determine icon and colors based on jenis_iuran
    IconData iconData = Icons.receipt_long;
    Color iconBackgroundColor = Colors.grey.shade100;
    Color iconColor = Colors.grey;

    if (jenisIuran.toLowerCase().contains('kebersihan')) {
      iconData = Icons.delete_outline;
      iconBackgroundColor = const Color(0xFFF0F4F8);
      iconColor = const Color(0xFF38644A);
    } else if (jenisIuran.toLowerCase().contains('keamanan')) {
      iconData = Icons.security_outlined;
      iconBackgroundColor = const Color(0xFFFFF8E1);
      iconColor = const Color(0xFFF57F17);
    }

    // Determine status colors
    Color statusBgColor = Colors.grey.shade200;
    Color statusTextColor = Colors.grey.shade700;

    if (status == 'LUNAS') {
      statusBgColor = const Color(0xFFD4F5E6);
      statusTextColor = const Color(0xFF2E7D32);
    } else if (status == 'PENDING' || status == 'BELUM') {
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFE65100);
      status = status == 'BELUM' ? 'PENDING' : status; // Matching UI visual pending state
    } else if (status == 'DITOLAK') {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => UserDetailPage(iuranData: item)));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$jenisIuran - $bulan $tahun',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'RobotoMedium',
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(nominal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      fontFamily: 'RobotoBlack',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusTextColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
}

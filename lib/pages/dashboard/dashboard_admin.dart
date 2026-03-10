import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'package:pie_chart/pie_chart.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  String _namaUser = "Admin";
  String _totalWarga = "0";
  String _totalKeluarga = "0";
  String _totalLansia = "0"; // Variabel baru buat lansia
  int _jmlMandiri = 0;
  int _jmlMadya = 0;
  int _jmlPrasejahtera = 0;
  int _totalRasio = 0;
  double _persentaseRasio = 0.0; // Ini buat CircularProgress
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchStats(); // Ambil semua data pas halaman dibuka
    _selectedDay = _focusedDay;
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _namaUser = prefs.getString('nama_user') ?? "Admin";
    });
  }

  // Fungsi sakti buat ambil semua data statistik sekaligus
  Future<void> _fetchStats() async {
    try {
      final results = await Future.wait([
        ApiService.get(ApiUrl.totalWarga),
        ApiService.get(ApiUrl.totalKeluarga),
        ApiService.get(ApiUrl.totalLansia),
        ApiService.get("${ApiUrl.baseUrl}/keluarga/get_rasio.php"), // Panggil API rasio
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['status'] == true) _totalWarga = results[0]['total_warga'].toString();
          if (results[1]['status'] == true) _totalKeluarga = results[1]['total_keluarga'].toString();
          if (results[2]['status'] == true) _totalLansia = results[2]['total_lansia'].toString();

          // Logika itung Rasio
          if (results[3]['status'] == true) {
            var data = results[3]['data'];
            _jmlMandiri = data['mandiri'];
            _jmlMadya = data['madya'];
            _jmlPrasejahtera = data['prasejahtera'];
            _totalRasio = data['total'];

            // Itung persentase (Mandiri + Madya dibagi Total)
            // Biar chart-nya nampilin tingkat kesejahteraan
            if (_totalRasio > 0) {
              _persentaseRasio = (_jmlMandiri + _jmlMadya) / _totalRasio;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error Stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildNewHeader(_namaUser),
                _buildCalendarCard(),
                const SizedBox(height: 10),
                _buildHorizontalStats(), // Sekarang angka di sini dinamis
                _buildRasioKeluargaCard(),
                _buildMenuGrid(context),
                _buildRecentActivity(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavbar()),
        ],
      ),
    );
  }

  Widget _buildNewHeader(String nama) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.settings, color: Colors.white),
              Text('Selamat Datang, $nama', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              const Icon(Icons.notifications, color: Colors.white),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Cari warga...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(25)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white70),
          todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          selectedDecoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          selectedTextStyle: TextStyle(color: Color(0xFF2D4B1E), fontWeight: FontWeight.bold),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHorizontalStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: [
          _buildStatBox(Icons.people_outline, _totalWarga, "Total Warga"),
          _buildStatBox(Icons.home_outlined, _totalKeluarga, "Total Keluarga"),
          _buildStatBox(Icons.favorite_border, _totalLansia, "Lansia Terdata"), // Dinamis
          _buildStatBox(Icons.wallet, "1.525.000", "Saldo Iuran"),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String val, String label) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(height: 10),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRasioKeluargaCard() {
    // Map data buat dikirim ke PieChart
    Map<String, double> dataMap = {
      "Mandiri": _jmlMandiri.toDouble(),
      "Madya": _jmlMadya.toDouble(),
      "Prasejahtera": _jmlPrasejahtera.toDouble(),
    };

    // List warna sesuai desain lu
    final colorList = <Color>[
      const Color(0xFF2D4B1E), // Hijau Tua
      const Color(0xFF8CAF5D), // Hijau Muda
      Colors.orange,           // Orange
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rasio Keluarga", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildLegend(colorList[0], "Mandiri ($_jmlMandiri)"),
                _buildLegend(colorList[1], "Madya ($_jmlMadya)"),
                _buildLegend(colorList[2], "Prasejahtera ($_jmlPrasejahtera)"),
              ],
            ),
          ),
          // Ganti CircularProgressIndicator dengan PieChart
          SizedBox(
            height: 100,
            width: 100,
            child: PieChart(
              dataMap: dataMap,
              animationDuration: const Duration(milliseconds: 800),
              chartLegendSpacing: 0,
              chartRadius: 80,
              colorList: colorList,
              initialAngleInDegree: 0,
              chartType: ChartType.ring, // Pakai ring biar tengahnya bolong
              ringStrokeWidth: 12,
              legendOptions: const LegendOptions(showLegends: false), // Sembunyiin legend bawaan
              chartValuesOptions: const ChartValuesOptions(showChartValues: false), // Sembunyiin angka di dalem chart
              centerText: "${(_persentaseRasio * 100).toInt()}%", // Persen di tengah
              centerTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color c, String t) {
    return Row(children: [Container(width: 10, height: 10, color: c), const SizedBox(width: 5), Text(t, style: const TextStyle(fontSize: 10))]);
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      padding: const EdgeInsets.all(20),
      children: [
        _buildMenuIcon(context, Icons.person, "Data Warga", '/manage_warga'),
        _buildMenuIcon(context, Icons.people, "Data Keluarga", '/manage_keluarga'),
        _buildMenuIcon(context, Icons.wallet, "Input Iuran", '/manage_iuran'),
        _buildMenuIcon(context, Icons.verified_user, "Verifikasi", '/verifikasi'),
        _buildMenuIcon(context, Icons.home_work, "Posyandu", '/posyandu'),
        _buildMenuIcon(context, Icons.assignment, "Jumantik", '/riwayat_jumantik'),
        _buildMenuIcon(context, Icons.campaign, "Info RT", '/riwayat_pengumuman'),
        _buildMenuIcon(context, Icons.description, "Rekap", '/rekap'),
      ],
    );
  }

  Widget _buildMenuIcon(BuildContext context, IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildActivityCard(Icons.wallet, "Kel. Budi membayar iuran Maret.", Colors.orange),
          _buildActivityCard(Icons.person_add, "Warga Baru (Andi) perlu verifikasi.", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildActivityCard(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))]),
    );
  }

  Widget _buildBottomNavbar() {
    return Container(
      height: 70,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF2D4B1E), borderRadius: BorderRadius.circular(30)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [Icon(Icons.home, color: Colors.white), Icon(Icons.people_outline, color: Colors.white54), Icon(Icons.wallet_outlined, color: Colors.white54), Icon(Icons.person_outline, color: Colors.white54)]),
    );
  }
}
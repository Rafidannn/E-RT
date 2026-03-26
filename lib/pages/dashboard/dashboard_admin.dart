import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:pie_chart/pie_chart.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import '../profil/profil_admin_page.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  // --- STATE DATA ---
  String _namaUser = "Admin";
  String _totalWarga = "0";
  String _totalKeluarga = "0";
  String _totalLansia = "0";
  String _saldoIuran = "1.525.000"; // Nanti bisa tembak API Saldo juga

  int _jmlMandiri = 0, _jmlMadya = 0, _jmlPrasejahtera = 0, _totalRasio = 0;
  double _persentaseKesejahteraan = 0.0;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    await _loadUserData();
    await _fetchStats();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _namaUser = prefs.getString('nama_user') ?? "Admin");
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.get(ApiUrl.totalWarga),
        ApiService.get(ApiUrl.totalKeluarga),
        ApiService.get(ApiUrl.totalLansia),
        ApiService.get("${ApiUrl.baseUrl}/keluarga/get_rasio.php"),
      ]);

      if (mounted) {
        setState(() {
          if (results[0]['status'] == true) _totalWarga = results[0]['total_warga'].toString();
          if (results[1]['status'] == true) _totalKeluarga = results[1]['total_keluarga'].toString();
          if (results[2]['status'] == true) _totalLansia = results[2]['total_lansia'].toString();

          if (results[3]['status'] == true) {
            var data = results[3]['data'];
            _jmlMandiri = data['mandiri'] ?? 0;
            _jmlMadya = data['madya'] ?? 0;
            _jmlPrasejahtera = data['prasejahtera'] ?? 0;
            _totalRasio = data['total'] ?? 0;
            if (_totalRasio > 0) {
              _persentaseKesejahteraan = (_jmlMandiri + _jmlMadya) / _totalRasio;
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error Dashboard Stats: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchStats,
            color: const Color(0xFF2D4B1E),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 1. HEADER HIJAU DENGAN SEARCH BAR
                  _buildHeader(_namaUser),

                  // 2. KALENDER CARD
                  _buildCalendarCard(),

                  // 3. STATISTIK HORIZONTAL (ANGKA DINAMIS)
                  _buildHorizontalStats(),

                  // 4. RASIO KELUARGA DENGAN PIE CHART
                  _buildRasioKeluargaCard(),

                  // 5. MENU GRID UTAMA
                  _buildMenuGrid(context),

                  // 6. AKTIVITAS TERBARU
                  _buildRecentActivity(),

                  const SizedBox(height: 120), // Spacer Navbar
                ],
              ),
            ),
          ),

          // 7. BOTTOM NAVBAR
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNavbar(context)),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader(String nama) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.settings_outlined, color: Colors.white),
              Text(
                'Selamat Datang, $nama',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
              ),
              const Icon(Icons.notifications_none, color: Colors.white),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            decoration: InputDecoration(
              hintText: "Cari data warga atau keluarga...",
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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(25)),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) => setState(() { _selectedDay = selectedDay; _focusedDay = focusedDay; }),
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: Colors.white, fontSize: 12),
          weekendTextStyle: TextStyle(color: Colors.white70, fontSize: 12),
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
        daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.white), weekendStyle: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildHorizontalStats() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildStatBox(Icons.people_outline, _totalWarga, "Total Warga", '/manage_warga'),
          _buildStatBox(Icons.home_outlined, _totalKeluarga, "Total Keluarga", '/manage_keluarga'),
          _buildStatBox(Icons.favorite_border, _totalLansia, "Lansia Terdata", '/manage_warga'),
          _buildStatBox(Icons.account_balance_wallet_outlined, _saldoIuran, "Saldo Iuran", '/manage_iuran'),
        ],
      ),
    );
  }

  Widget _buildStatBox(IconData icon, String val, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF2D4B1E), size: 30),
            const SizedBox(height: 10),
            Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildRasioKeluargaCard() {
    Map<String, double> dataMap = {
      "Mandiri": _jmlMandiri.toDouble(),
      "Madya": _jmlMadya.toDouble(),
      "Prasejahtera": _jmlPrasejahtera.toDouble(),
    };

    final colorList = <Color>[const Color(0xFF2D4B1E), const Color(0xFF8CAF5D), Colors.orange];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Rasio Keluarga", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildLegend(colorList[0], "Mandiri ($_jmlMandiri)"),
                _buildLegend(colorList[1], "Madya ($_jmlMadya)"),
                _buildLegend(colorList[2], "Prasejahtera ($_jmlPrasejahtera)"),
              ],
            ),
          ),
          SizedBox(
            height: 100, width: 100,
            child: PieChart(
              dataMap: dataMap,
              colorList: colorList,
              chartType: ChartType.ring,
              ringStrokeWidth: 12,
              chartRadius: 80,
              legendOptions: const LegendOptions(showLegends: false),
              chartValuesOptions: const ChartValuesOptions(showChartValues: false),
              centerText: "${(_persentaseKesejahteraan * 100).toInt()}%",
              centerTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color c, String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [Container(width: 12, height: 12, color: c), const SizedBox(width: 8), Text(t, style: const TextStyle(fontSize: 11))]),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 20,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
        children: [
          _buildMenuIcon(Icons.person_outline, "Data Warga", '/manage_warga'),
          _buildMenuIcon(Icons.people_outline, "Data Keluarga", '/manage_keluarga'),
          _buildMenuIcon(Icons.account_balance_wallet_outlined, "Riwayat Iuran", '/manage_iuran'),
          _buildMenuIcon(Icons.verified_user_outlined, "Verifikasi", '/verifikasi'),
          _buildMenuIcon(Icons.home_work_outlined, "Posyandu", '/posyandu'),
          _buildMenuIcon(Icons.assignment_outlined, "Jumantik", '/riwayat_jumantik'),
          _buildMenuIcon(Icons.campaign_outlined, "Info RT", '/riwayat_pengumuman'),
          _buildMenuIcon(Icons.description_outlined, "Rekap", '/rekap'),
        ],
      ),
    );
  }

  Widget _buildMenuIcon(IconData icon, String label, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF8CAF5D), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Recent Activity", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildActivityCard(Icons.wallet, "Kel. Budi membayar iuran Maret.", Colors.orange),
          _buildActivityCard(Icons.person_add, "Warga Baru (Andi) perlu verifikasi.", Colors.blue),
        ],
      ),
    );
  }

  Widget _buildActivityCard(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(15)),
      child: Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 15), Expanded(child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)))]),
    );
  }

  Widget _buildBottomNavbar(BuildContext context) {
    return Container(
      height: 80,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: const Color(0xFF2D4B1E), borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home, color: Colors.white, size: 28),
          IconButton(icon: const Icon(Icons.people_outline, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/manage_warga')),
          IconButton(icon: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white70), onPressed: () => Navigator.pushNamed(context, '/manage_iuran')),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white70),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilAdminPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

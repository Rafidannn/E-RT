import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RiwayatIuranUserPage extends StatefulWidget {
  final String idKeluarga; // Diambil dari data login/session
  const RiwayatIuranUserPage({super.key, required this.idKeluarga});

  @override
  State<RiwayatIuranUserPage> createState() => _RiwayatIuranUserPageState();
}

class _RiwayatIuranUserPageState extends State<RiwayatIuranUserPage> {
  List<dynamic> _allData = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = true;
  String _currentFilter = "Semua";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post(ApiUrl.getIuranByUser, {
        'id_keluarga': widget.idKeluarga,
      });

      if (res['status'] == 'success') {
        setState(() {
          _allData = res['data'];
          _applyFilter(_currentFilter);
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == "Semua") {
        _filteredData = _allData;
      } else {
        _filteredData = _allData.where((item) =>
        item['status'].toString().toLowerCase() == filter.toLowerCase()
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Riwayat Iuran Saya",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Header Dekoratif
          _buildHeaderSection(),

          // Filter Chips
          _buildFilterSection(),

          // List Data
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
                : RefreshIndicator(
              onRefresh: _fetchData,
              child: _filteredData.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  return _buildIuranCard(_filteredData[index]);
                },
              ),
            ),
          ),
        ],
      ),
      // Tombol melayang buat tambah/konfirmasi bayar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/input_iuran_user');
          if (result == true) _fetchData();
        },
        backgroundColor: const Color(0xFF8BAE51),
        icon: const Icon(Icons.add_card, color: Colors.white),
        label: const Text("Bayar Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.history_edu_rounded, color: Colors.white, size: 50),
          SizedBox(height: 10),
          Text("Cek status iuran bulanan Anda",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ["Semua", "Lunas", "Belum"].map((filter) {
          bool isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: const Color(0xFF2D4B1E),
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
              onSelected: (bool selected) {
                if (selected) _applyFilter(filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIuranCard(dynamic item) {
    bool isLunas = item['status'].toString().toLowerCase() == 'lunas';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isLunas ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
            child: Icon(
              isLunas ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
              color: isLunas ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['jenis_iuran'] ?? "Iuran Warga",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${item['bulan']} ${item['tahun']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Rp ${item['nominal']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isLunas ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item['status'].toString().toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Tidak ada data iuran ditemukan", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
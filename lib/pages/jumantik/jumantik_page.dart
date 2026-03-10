import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Tambahin di pubspec.yaml kalo belum ada

class JumantikPage extends StatefulWidget {
  const JumantikPage({super.key});

  @override
  State<JumantikPage> createState() => _JumantikPageState();
}

class _JumantikPageState extends State<JumantikPage> {
  final _formKey = GlobalKey<FormState>();

  List<dynamic> _listKeluarga = [];
  List<dynamic> _listAdmin = []; // Buat nampung daftar petugas

  String? _selectedKeluargaId;
  String? _selectedPetugasId;
  DateTime _selectedDate = DateTime.now();
  String _statusJentik = "tidak";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchKeluarga();
    _fetchAdmin(); // Ambil daftar petugas dari tabel users
    _loadInitialPetugas();
  }

  // Load petugas yang lagi login sebagai default
  Future<void> _loadInitialPetugas() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedPetugasId = prefs.getString('id_user') ?? prefs.getString('id');
    });
  }

  Future<void> _fetchKeluarga() async {
    try {
      final response = await ApiService.get(ApiUrl.listKeluargaDropdown);
      if (response['status'] == true) {
        setState(() => _listKeluarga = response['data']);
      }
    } catch (e) { debugPrint("Error Keluarga: $e"); }
  }

  // Ambil daftar petugas (Admin/Kader) dari database
  Future<void> _fetchAdmin() async {
    try {
      // Buat endpoint baru di ApiUrl: static const String getAdmin = '$baseUrl/auth/get_admin.php';
      final response = await ApiService.get("${ApiUrl.baseUrl}/auth/get_admin.php");
      if (response['status'] == true) {
        setState(() => _listAdmin = response['data']);
      }
    } catch (e) { debugPrint("Error Admin: $e"); }
  }

  // Fungsi Pilih Tanggal
  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _simpanLaporan() async {
    // DEBUG: Cek isi variabel tepat sebelum dikirim
    print("--- DEBUG DATA SEBELUM KIRIM ---");
    print("Keluarga ID: $_selectedKeluargaId");
    print("Status Jentik: $_statusJentik");
    print("Tanggal: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}");
    print("Petugas ID: $_selectedPetugasId");
    print("--------------------------------");

    if (_selectedKeluargaId == null || _selectedPetugasId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID Keluarga atau Petugas masih KOSONG cok!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Pastiin key-nya sama persis dengan $_POST di PHP
      Map<String, dynamic> data = {
        'id_keluarga': _selectedKeluargaId,
        'status_jentik': _statusJentik,
        'tanggal': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'petugas': _selectedPetugasId,
      };

      final response = await ApiService.post(ApiUrl.postJumantik, data);

      if (response['status'] == true) {
        Navigator.pop(context, true);
      } else {
        // Ini yang muncul di log lu tadi
        print("GAGAL DARI DATABASE: ${response['message']}");
      }
    } catch (e) {
      print("ERROR SYSTEM: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Data Jumantik")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Pilih Tanggal
            const Text("Tanggal Pemeriksaan", style: TextStyle(fontWeight: FontWeight.bold)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(DateFormat('dd MMMM yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),

            // 2. Pilih Keluarga
            const Text("Pilih Keluarga", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedKeluargaId,
              hint: const Text("Pilih Kepala Keluarga"),
              items: _listKeluarga.map((item) => DropdownMenuItem(
                value: item['id_keluarga'].toString(),
                child: Text(item['nama_warga'].toString()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedKeluargaId = v),
            ),
            const SizedBox(height: 20),

            // 3. Status Jentik (Sama kayak kodingan sebelumnya)
            const Text("Status Jentik", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                _buildStatusOption("tidak", "Bebas Jentik", Colors.green),
                const SizedBox(width: 10),
                _buildStatusOption("ada", "Ada Jentik", Colors.red),
              ],
            ),
            const SizedBox(height: 20),

            // 4. Pilih Petugas (Manual)
            const Text("Petugas Pemeriksa", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedPetugasId,
              hint: const Text("Pilih Petugas"),
              items: _listAdmin.map((item) => DropdownMenuItem(
                value: item['id_user'].toString(),
                child: Text(item['nama'].toString()),
              )).toList(),
              onChanged: (v) => setState(() => _selectedPetugasId = v),
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _simpanLaporan, child: const Text("SIMPAN")),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(String val, String label, Color color) {
    bool isSelected = _statusJentik == val;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _statusJentik = val),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.white,
              border: Border.all(color: isSelected ? color : Colors.grey),
              borderRadius: BorderRadius.circular(10)
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? color : Colors.black)),
        ),
      ),
    );
  }
}
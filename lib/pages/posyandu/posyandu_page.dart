import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class PosyanduPage extends StatefulWidget {
  const PosyanduPage({super.key});

  @override
  State<PosyanduPage> createState() => _PosyanduPageState();
}

class _PosyanduPageState extends State<PosyanduPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- STATE RIWAYAT ---
  List<dynamic> _listRiwayat = [];
  bool _isLoadingRiwayat = true;

  // --- STATE INPUT ---
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _beratCtrl = TextEditingController();
  final TextEditingController _tinggiCtrl = TextEditingController();
  final TextEditingController _hasilCtrl = TextEditingController();

  String? _selectedWargaId;
  String _selectedKategori = 'balita';
  List<dynamic> _listWarga = [];
  bool _isSaving = false;
  bool _isLoadingWarga = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRiwayat();
    _fetchWarga();
  }

  // --- AMBIL DATA WARGA (Sesuai dengan get.php status 'success') ---
  Future<void> _fetchWarga() async {
    setState(() => _isLoadingWarga = true);
    try {
      final res = await ApiService.get(ApiUrl.getWarga);

      // Sinkronisasi dengan PHP kamu yang pakai "success"
      if (res['status'] == 'success') {
        setState(() {
          // Mapping data agar id_warga jadi String dan nama tetap terbaca
          _listWarga = (res['data'] as List).map((w) {
            return {
              'id_warga': w['id_warga'].toString(),
              'nama': w['nama'],
            };
          }).toList();
          _isLoadingWarga = false;
        });
        debugPrint("Data warga berhasil dimuat: ${_listWarga.length} orang");
      }
    } catch (e) {
      debugPrint("Error Load Warga: $e");
      setState(() => _isLoadingWarga = false);
    }
  }

  Future<void> _fetchRiwayat() async {
    setState(() => _isLoadingRiwayat = true);
    try {
      final res = await ApiService.get(ApiUrl.getPosyandu);
      // Asumsi get_history.php pakai status: true (boolean)
      if (res['status'] == true) {
        setState(() => _listRiwayat = res['data']);
      }
    } catch (e) {
      debugPrint("Error Riwayat: $e");
    } finally {
      if (mounted) setState(() => _isLoadingRiwayat = false);
    }
  }

  Future<void> _simpanData() async {
    if (!_formKey.currentState!.validate() || _selectedWargaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pilih warga dan lengkapi data!"))
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final data = {
        'id_warga': _selectedWargaId,
        'kategori': _selectedKategori,
        'berat_badan': _beratCtrl.text,
        'tinggi_badan': _tinggiCtrl.text,
        'hasil': _hasilCtrl.text,
        'petugas': '1',
      };

      final res = await ApiService.post(ApiUrl.postPosyandu, data);

      if (res['status'] == true) {
        _tabController.animateTo(0); // Pindah ke tab riwayat
        _fetchRiwayat(); // Refresh data riwayat
        _formKey.currentState!.reset();
        _beratCtrl.clear();
        _tinggiCtrl.clear();
        _hasilCtrl.clear();
        setState(() => _selectedWargaId = null);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Data Berhasil Disimpan"))
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Layanan Posyandu", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8BAE51),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.history), text: "Riwayat"),
            Tab(icon: Icon(Icons.add_chart), text: "Input Data"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabRiwayat(),
          _buildTabInput(),
        ],
      ),
    );
  }

  // --- TAB 1: LIST RIWAYAT ---
  Widget _buildTabRiwayat() {
    if (_isLoadingRiwayat) return const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)));
    if (_listRiwayat.isEmpty) return const Center(child: Text("Belum ada riwayat pemeriksaan"));

    return RefreshIndicator(
      onRefresh: _fetchRiwayat,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _listRiwayat.length,
        itemBuilder: (context, index) {
          final item = _listRiwayat[index];
          bool isBalita = item['kategori'] == 'balita';
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isBalita ? Colors.blue[50] : Colors.orange[50],
                child: Icon(isBalita ? Icons.child_care : Icons.person, color: isBalita ? Colors.blue : Colors.orange),
              ),
              title: Text(item['nama_warga'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("BB: ${item['berat_badan']}kg | TB: ${item['tinggi_badan']}cm\nHasil: ${item['hasil']}"),
              trailing: Text(item['tanggal'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  // --- TAB 2: FORM INPUT ---
  Widget _buildTabInput() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pilih Warga", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4B1E))),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _selectedWargaId,
              hint: Text(_isLoadingWarga ? "Memuat data warga..." : "Pilih Nama Warga"),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                filled: true,
                fillColor: Colors.white,
              ),
              items: _listWarga.isEmpty ? [] : _listWarga.map((w) {
                return DropdownMenuItem<String>(
                  value: w['id_warga'].toString(),
                  child: Text(w['nama'] ?? "-"),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => _selectedWargaId = val);
              },
              validator: (v) => v == null ? "Wajib pilih warga" : null,
            ),

            const SizedBox(height: 20),
            const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D4B1E))),
            Row(
              children: [
                Expanded(child: RadioListTile(title: const Text("Balita"), value: 'balita', groupValue: _selectedKategori, activeColor: const Color(0xFF2D4B1E), onChanged: (v) => setState(() => _selectedKategori = v!))),
                Expanded(child: RadioListTile(title: const Text("Lansia"), value: 'lansia', groupValue: _selectedKategori, activeColor: const Color(0xFF2D4B1E), onChanged: (v) => setState(() => _selectedKategori = v!))),
              ],
            ),

            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _fieldInput(_beratCtrl, "Berat (kg)", TextInputType.number)),
                const SizedBox(width: 15),
                Expanded(child: _fieldInput(_tinggiCtrl, "Tinggi (cm)", TextInputType.number)),
              ],
            ),

            const SizedBox(height: 20),
            _fieldInput(_hasilCtrl, "Hasil Analisa / Catatan", TextInputType.text, maxLines: 3),

            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D4B1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: _isSaving ? null : _simpanData,
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN DATA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _fieldInput(TextEditingController ctrl, String label, TextInputType type, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }
}
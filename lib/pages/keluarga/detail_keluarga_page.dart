import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class DetailKeluargaPage extends StatefulWidget {
  final String idKeluarga;
  const DetailKeluargaPage({super.key, required this.idKeluarga});

  @override
  State<DetailKeluargaPage> createState() => _DetailKeluargaPageState();
}

class _DetailKeluargaPageState extends State<DetailKeluargaPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      // Panggil detail pake parameter:
      final response = await ApiService.get("${ApiUrl.getDetailKeluarga}?id_keluarga=${widget.idKeluarga}");
      if (response['status'] == true) {
        setState(() => _data = response['data']);
      }
    } catch (e) {
      debugPrint("Error Fetch Detail: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var info = _data?['info'];
    var listAnggota = _data?['anggota'] as List?;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Detail Keluarga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(info),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Informasi Tambahan"),
                  _buildDetailGrid(info),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Daftar Anggota Keluarga (${listAnggota?.length ?? 0})"),
                  const SizedBox(height: 10),
                  ...?listAnggota?.map((w) => _buildMemberItem(w)).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Color(0xFF2D4B1E),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("KEPALA KELUARGA", style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text(info['nama_kepala'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("No KK: ${info['no_kk']}", style: const TextStyle(color: Colors.white70)),
          const Divider(color: Colors.white24, height: 30),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(info['alamat_lengkap'] ?? '-', style: const TextStyle(color: Colors.white))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(dynamic info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Pake warna hijau muda transparan biar seger
        color: const Color(0xFF8CAF5D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8CAF5D).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _gridItem("Ekonomi", info['status_ekonomi'], Icons.payments_outlined),
              _gridItem("Sumber Air", info['sumber_air'], Icons.water_drop_outlined),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.black12),
          ),
          Row(
            children: [
              _gridItem("Jamban", info['memiliki_jamban'] == "1" ? "Ada" : "Tidak", Icons.wc_outlined),
              _gridItem("Sampah", info['pengelolaan_sampah'], Icons.delete_outline),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gridItem(String label, String? value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D4B1E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2D4B1E), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                  value ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem(dynamic w) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: w['jenis_kelamin'] == 'L' ? Colors.blue.shade50 : Colors.pink.shade50,
          child: Icon(w['jenis_kelamin'] == 'L' ? Icons.male : Icons.female, color: w['jenis_kelamin'] == 'L' ? Colors.blue : Colors.pink),
        ),
        title: Text(w['nama'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("NIK: ${w['nik']}\n${w['pekerjaan']}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D4B1E))),
    );
  }
}
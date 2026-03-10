import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class EditWargaPage extends StatefulWidget {
  final Map<String, dynamic> warga;
  const EditWargaPage({super.key, required this.warga});

  @override
  State<EditWargaPage> createState() => _EditWargaPageState();
}

class _EditWargaPageState extends State<EditWargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _namaCtrl, _nikCtrl, _tempatLahirCtrl, _tglLahirCtrl, _pendidikanCtrl, _pekerjaanCtrl;
  late String _jenisKelamin, _statusKesehatan, _statusKawin;
  late int _bpjsAktif;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.warga['nama']?.toString());
    _nikCtrl = TextEditingController(text: widget.warga['nik']?.toString());
    _tempatLahirCtrl = TextEditingController(text: widget.warga['tempat_lahir']?.toString());
    _tglLahirCtrl = TextEditingController(text: widget.warga['tanggal_lahir']?.toString());
    _pendidikanCtrl = TextEditingController(text: widget.warga['pendidikan']?.toString());
    _pekerjaanCtrl = TextEditingController(text: widget.warga['pekerjaan']?.toString());

    _jenisKelamin = widget.warga['jenis_kelamin'] ?? 'L';
    _statusKesehatan = widget.warga['status_kesehatan_khusus'] ?? 'umum';
    _statusKawin = widget.warga['status_perkawinan'] ?? 'belum_kawin';
    _bpjsAktif = int.tryParse(widget.warga['bpjs_aktif'].toString()) ?? 1;
  }

  Future<void> _updateWarga() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final body = {
        'id_warga': widget.warga['id_warga'],
        'id_keluarga': widget.warga['id_keluarga'],
        'nama': _namaCtrl.text,
        'nik': _nikCtrl.text,
        'tempat_lahir': _tempatLahirCtrl.text,
        'tanggal_lahir': _tglLahirCtrl.text,
        'jenis_kelamin': _jenisKelamin,
        'pendidikan': _pendidikanCtrl.text,
        'pekerjaan': _pekerjaanCtrl.text,
        'status_perkawinan': _statusKawin,
        'status_kesehatan_khusus': _statusKesehatan,
        'bpjs_aktif': _bpjsAktif,
      };

      final res = await ApiService.post(ApiUrl.updateWarga, body);
      if (res['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data berhasil diupdate"), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      debugPrint("Update Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Warga", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D4B1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInput(_namaCtrl, "Nama Lengkap", Icons.person),
              const SizedBox(height: 15),
              _buildInput(_nikCtrl, "NIK", Icons.badge, isNum: true),
              const SizedBox(height: 15),
              _buildInput(_tempatLahirCtrl, "Tempat Lahir", Icons.map),
              const SizedBox(height: 15),
              _buildInput(_tglLahirCtrl, "Tgl Lahir (YYYY-MM-DD)", Icons.calendar_today),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateWarga,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D4B1E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: const Color(0xFF2D4B1E)), border: const OutlineInputBorder()),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }
}
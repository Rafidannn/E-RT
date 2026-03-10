import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class TambahWargaPage extends StatefulWidget {
  const TambahWargaPage({super.key});

  @override
  State<TambahWargaPage> createState() => _TambahWargaPageState();
}

class _TambahWargaPageState extends State<TambahWargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller Teks
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nikCtrl = TextEditingController();
  final TextEditingController _tempatLahirCtrl = TextEditingController();
  final TextEditingController _tglLahirCtrl = TextEditingController();
  final TextEditingController _pendidikanCtrl = TextEditingController();
  final TextEditingController _pekerjaanCtrl = TextEditingController();

  // State Input default
  String _jenisKelamin = 'L';
  String _statusKesehatan = 'umum';
  String _statusKawin = 'belum_kawin';
  int _bpjsAktif = 1;

  // Fungsi Pilih Tanggal biar user gak ngetik manual
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D4B1E), // warna header
              onPrimary: Colors.white, // warna teks header
              onSurface: Colors.black, // warna angka
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _tglLahirCtrl.text = picked.toString().split(' ')[0]);
    }
  }

  // Fungsi Kirim ke API
  Future<void> _simpanWarga() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final body = {
        'id_keluarga': '1', // Default ID, silakan disesuaikan logicnya nanti
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

      final response = await ApiService.post(ApiUrl.postWarga, body);

      // Cek response 'success' sesuai PHP lu
      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Warga Berhasil Ditambahkan!"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Balik ke list dengan bawa sinyal refresh
        }
      } else {
        throw Exception(response['message'] ?? "Gagal menyimpan data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Warga",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Dekoratif
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF2D4B1E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInput(_nikCtrl, "NIK", Icons.badge, isNum: true),
                    const SizedBox(height: 15),
                    _buildInput(_namaCtrl, "Nama Lengkap", Icons.person),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildInput(_tempatLahirCtrl, "Tempat Lahir", Icons.map)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _tglLahirCtrl,
                            readOnly: true,
                            onTap: _selectDate,
                            decoration: const InputDecoration(
                              labelText: "Tgl Lahir",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_month),
                            ),
                            validator: (v) => v!.isEmpty ? "Isi tgl" : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text("Jenis Kelamin", style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Radio(
                          value: 'L',
                          groupValue: _jenisKelamin,
                          activeColor: const Color(0xFF2D4B1E),
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text("Laki-laki"),
                        const SizedBox(width: 20),
                        Radio(
                          value: 'P',
                          groupValue: _jenisKelamin,
                          activeColor: const Color(0xFF2D4B1E),
                          onChanged: (v) => setState(() => _jenisKelamin = v!),
                        ),
                        const Text("Perempuan"),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildInput(_pendidikanCtrl, "Pendidikan", Icons.school),
                    const SizedBox(height: 15),
                    _buildInput(_pekerjaanCtrl, "Pekerjaan", Icons.work),
                    const SizedBox(height: 20),

                    const Text("Status Perkawinan", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: _statusKawin,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'belum_kawin', child: Text("Belum Kawin")),
                        DropdownMenuItem(value: 'kawin', child: Text("Kawin")),
                        DropdownMenuItem(value: 'cerai_hidup', child: Text("Cerai Hidup")),
                        DropdownMenuItem(value: 'cerai_mati', child: Text("Cerai Mati")),
                      ],
                      onChanged: (v) => setState(() => _statusKawin = v.toString()),
                    ),

                    const SizedBox(height: 20),
                    const Text("Kategori Kesehatan Khusus", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField(
                      value: _statusKesehatan,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'umum', child: Text("Umum")),
                        DropdownMenuItem(value: 'bumil', child: Text("Ibu Hamil")),
                        DropdownMenuItem(value: 'lansia', child: Text("Lansia")),
                        DropdownMenuItem(value: 'disabilitas', child: Text("Disabilitas")),
                      ],
                      onChanged: (v) => setState(() => _statusKesehatan = v.toString()),
                    ),

                    const SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SwitchListTile(
                        title: const Text("BPJS Aktif", style: TextStyle(fontWeight: FontWeight.bold)),
                        value: _bpjsAktif == 1,
                        activeColor: const Color(0xFF2D4B1E),
                        onChanged: (v) => setState(() => _bpjsAktif = v ? 1 : 0),
                      ),
                    ),

                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpanWarga,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D4B1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("SIMPAN DATA WARGA",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2D4B1E)),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF2D4B1E), width: 2),
        ),
      ),
      validator: (v) => v!.isEmpty ? "Bidang ini wajib diisi" : null,
    );
  }
}
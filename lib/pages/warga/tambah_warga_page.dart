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

  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _nikCtrl = TextEditingController();
  final TextEditingController _tempatLahirCtrl = TextEditingController();
  final TextEditingController _tglLahirCtrl = TextEditingController();
  final TextEditingController _pendidikanCtrl = TextEditingController();
  final TextEditingController _pekerjaanCtrl = TextEditingController();

  String _jenisKelamin = 'L';
  String _statusKesehatan = 'umum';
  String _statusKawin = 'belum_kawin';
  int _bpjsAktif = 1;

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nikCtrl.dispose();
    _tempatLahirCtrl.dispose();
    _tglLahirCtrl.dispose();
    _pendidikanCtrl.dispose();
    _pekerjaanCtrl.dispose();
    super.dispose();
  }

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

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Warga Berhasil Ditambahkan!"), backgroundColor: Colors.green));
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['message'] ?? "Gagal menyimpan data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tglLahirCtrl.text.isNotEmpty 
          ? DateTime.tryParse(_tglLahirCtrl.text) ?? DateTime.now()
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2D4B1E), // header bg
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _tglLahirCtrl.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0, bottom: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF334A28),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
          ),
          Positioned(
            top: 300, left: 0, right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.3,
                child: Image.asset('assets/images/logo_ert.png', width: 250, fit: BoxFit.contain),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField("Nama Lengkap", _namaCtrl),
                          const SizedBox(height: 15),
                          _buildTextField("NIK", _nikCtrl, isNum: true),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(child: _buildTextField("Tempat Lahir", _tempatLahirCtrl)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildTextField(
                                  "Tgl Lahir (YYYY-MM-DD)", 
                                  _tglLahirCtrl, 
                                  readOnly: true, 
                                  onTap: () => _selectDate(context)
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildDropdown("Jenis Kelamin", _jenisKelamin, [
                            const DropdownMenuItem(value: 'L', child: Text("Laki-laki", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'P', child: Text("Perempuan", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _jenisKelamin = v as String)),
                          const SizedBox(height: 15),
                          _buildTextField("Pendidikan", _pendidikanCtrl),
                          const SizedBox(height: 15),
                          _buildTextField("Pekerjaan", _pekerjaanCtrl),
                          const SizedBox(height: 15),
                          _buildDropdown("Status Perkawinan", _statusKawin, [
                            const DropdownMenuItem(value: 'belum_kawin', child: Text("Belum Kawin", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'kawin', child: Text("Kawin", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'cerai_hidup', child: Text("Cerai Hidup", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'cerai_mati', child: Text("Cerai Mati", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _statusKawin = v as String)),
                          const SizedBox(height: 15),
                          _buildDropdown("Status Kesehatan Khusus", _statusKesehatan, [
                            const DropdownMenuItem(value: 'umum', child: Text("Umum / Sehat", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'bumil', child: Text("Ibu Hamil", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'lansia', child: Text("Lansia", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'disabilitas', child: Text("Disabilitas", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'sakit_kronis', child: Text("Sakit Kronis", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _statusKesehatan = v as String)),
                          const SizedBox(height: 15),
                          _buildDropdown("Status BPJS", _bpjsAktif.toString(), [
                            const DropdownMenuItem(value: '1', child: Text("Aktif", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: '0', child: Text("Tidak Aktif / Tidak Ada", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _bpjsAktif = int.parse(v as String))),
                          
                          const SizedBox(height: 35),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8BA54D),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                elevation: 5,
                              ),
                              onPressed: _isLoading ? null : _simpanWarga,
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Simpan Data Warga", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
             decoration: BoxDecoration(
                color: const Color(0xFF8BA54D),
                borderRadius: BorderRadius.circular(20),
             ),
             child: const Text("Tambah Warga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController ctrl, {bool isNum = false, bool readOnly = false, VoidCallback? onTap}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFFAF7F2), borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: TextFormField(
          controller: ctrl,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.normal),
            border: InputBorder.none,
            isDense: true,
          ),
          validator: (v) => v!.isEmpty ? "Wajib" : null,
        ),
      ),
    );
  }

  Widget _buildDropdown(String hint, String value, List<DropdownMenuItem<String>> items, Function(String?) onChanged) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFFAF7F2), borderRadius: BorderRadius.circular(20)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

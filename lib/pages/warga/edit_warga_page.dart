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
                              onPressed: _isLoading ? null : _updateWarga,
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
             child: const Text("Edit Warga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.white, size: 28),
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
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20)),
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
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20)),
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

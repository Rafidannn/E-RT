import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class TambahKeluargaPage extends StatefulWidget {
  const TambahKeluargaPage({super.key});

  @override
  State<TambahKeluargaPage> createState() => _TambahKeluargaPageState();
}

class _TambahKeluargaPageState extends State<TambahKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFetchingWarga = true;

  // Controller Teks (Sesuai kolom di DB lu)
  final TextEditingController _noKkCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _rtRwCtrl = TextEditingController();
  final TextEditingController _penghasilanCtrl = TextEditingController(text: "0");
  final TextEditingController _sumberAirCtrl = TextEditingController();
  final TextEditingController _sampahCtrl = TextEditingController();

  // Dropdown & Toggle
  String _statusEkonomi = 'pra-sejahtera';
  String _memilikiJamban = '1';
  String _memilikiToga = '0';

  List<dynamic> _listWargaTanpaKK = [];
  String? _selectedKepalaId;

  @override
  void initState() {
    super.initState();
    _fetchWargaTanpaKK();
  }

  Future<void> _fetchWargaTanpaKK() async {
    try {
      final res = await ApiService.get(ApiUrl.getTanpaKK);
      if (res['status'] == true) {
        setState(() {
          _listWargaTanpaKK = res['data'];
          _isFetchingWarga = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isFetchingWarga = false);
    }
  }

  Future<void> _simpanKeluarga() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKepalaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih Kepala Keluarga!")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // KIRIM SEMUA DATA KE PHP
      final body = {
        'no_kk': _noKkCtrl.text,
        'alamat_lengkap': _alamatCtrl.text,
        'rt_rw': _rtRwCtrl.text,
        'penghasilan_bulanan': _penghasilanCtrl.text,
        'status_ekonomi': _statusEkonomi,
        'sumber_air': _sumberAirCtrl.text,
        'memiliki_jamban': int.parse(_memilikiJamban),
        'pengelolaan_sampah': _sampahCtrl.text,
        'memiliki_toga': int.parse(_memilikiToga),
        'id_kepala_keluarga': _selectedKepalaId,
      };

      final res = await ApiService.post(ApiUrl.postKeluarga, body);

      if (res['status'] == true) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Simpan Gagal: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Keluarga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D4B1E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isFetchingWarga
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 30, decoration: const BoxDecoration(color: Color(0xFF2D4B1E), borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Pilih Kepala Keluarga"),
                    DropdownButtonFormField<String>(
                      value: _selectedKepalaId,
                      isExpanded: true,
                      decoration: _inputDecoration(Icons.person),
                      items: _listWargaTanpaKK.map((w) => DropdownMenuItem(value: w['id_warga'].toString(), child: Text("${w['nama']} (${w['nik']})"))).toList(),
                      onChanged: (v) => setState(() => _selectedKepalaId = v),
                    ),
                    const SizedBox(height: 15),
                    _buildField(_noKkCtrl, "Nomor KK", Icons.badge, isNum: true),
                    const SizedBox(height: 15),
                    _buildField(_alamatCtrl, "Alamat Lengkap", Icons.home),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(child: _buildField(_rtRwCtrl, "RT/RW", Icons.map)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildField(_penghasilanCtrl, "Penghasilan", Icons.money, isNum: true)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildLabel("Status Ekonomi"),
                    DropdownButtonFormField<String>(
                      value: _statusEkonomi,
                      decoration: _inputDecoration(Icons.trending_up),
                      items: ['pra-sejahtera', 'madya', 'mandiri'].map((v) => DropdownMenuItem(value: v, child: Text(v.toUpperCase()))).toList(),
                      onChanged: (v) => setState(() => _statusEkonomi = v!),
                    ),
                    const SizedBox(height: 15),
                    _buildField(_sumberAirCtrl, "Sumber Air (PDAM/Sumur)", Icons.water_drop),
                    const SizedBox(height: 15),
                    _buildField(_sampahCtrl, "Pengelolaan Sampah", Icons.delete_sweep),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildDropdownSmall("Jamban", _memilikiJamban, (v) => setState(() => _memilikiJamban = v!))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildDropdownSmall("Toga", _memilikiToga, (v) => setState(() => _memilikiToga = v!))),
                      ],
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _simpanKeluarga,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D4B1E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("SIMPAN DATA KELUARGA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isNum = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(icon).copyWith(labelText: label),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  InputDecoration _inputDecoration(IconData icon) => InputDecoration(prefixIcon: Icon(icon, color: const Color(0xFF2D4B1E)), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))));

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _buildDropdownSmall(String label, String val, Function(String?) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<String>(
          value: val,
          items: const [DropdownMenuItem(value: '1', child: Text("Ada")), DropdownMenuItem(value: '0', child: Text("Tidak"))],
          onChanged: onChange,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
      ],
    );
  }
}

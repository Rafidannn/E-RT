import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class EditKeluargaPage extends StatefulWidget {
  final Map<String, dynamic> keluarga;
  const EditKeluargaPage({super.key, required this.keluarga});

  @override
  State<EditKeluargaPage> createState() => _EditKeluargaPageState();
}

class _EditKeluargaPageState extends State<EditKeluargaPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _noKkCtrl, _alamatCtrl, _sumberAirCtrl, _sampahCtrl;
  late String _statusEkonomi, _memilikiJamban;

  @override
  void initState() {
    super.initState();
    _noKkCtrl = TextEditingController(text: widget.keluarga['no_kk']?.toString());
    _alamatCtrl = TextEditingController(text: widget.keluarga['alamat_lengkap']?.toString());
    _sumberAirCtrl = TextEditingController(text: widget.keluarga['sumber_air']?.toString());
    _sampahCtrl = TextEditingController(text: widget.keluarga['pengelolaan_sampah']?.toString());

    String rawEkonomi = widget.keluarga['status_ekonomi']?.toString().toLowerCase().trim() ?? '';
    _statusEkonomi = ['pra-sejahtera', 'madya', 'mandiri'].contains(rawEkonomi) ? rawEkonomi : 'pra-sejahtera';
    
    _memilikiJamban = widget.keluarga['memiliki_jamban'].toString() == '1' ? '1' : '0';
  }

  Future<void> _updateKeluarga() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final body = {
        'id_keluarga': widget.keluarga['id_keluarga'],
        'no_kk': _noKkCtrl.text,
        'alamat_lengkap': _alamatCtrl.text,
        'sumber_air': _sumberAirCtrl.text,
        'pengelolaan_sampah': _sampahCtrl.text,
        'status_ekonomi': _statusEkonomi,
        'memiliki_jamban': _memilikiJamban,
      };

      final res = await ApiService.post(ApiUrl.updateKeluarga, body);

      if (res['status'] == true || res['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data keluarga berhasil diperbarui"), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(res['message'] ?? "Unknown error");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                          _buildTextField("Nomor KK", _noKkCtrl, isNum: true),
                          const SizedBox(height: 15),
                          _buildTextField("Alamat Lengkap", _alamatCtrl),
                          const SizedBox(height: 15),
                          _buildTextField("Sumber Air (PDAM/Sumur)", _sumberAirCtrl),
                          const SizedBox(height: 15),
                          _buildTextField("Pengelolaan Sampah", _sampahCtrl),
                          const SizedBox(height: 15),
                          _buildDropdown("Status Ekonomi", _statusEkonomi, [
                            const DropdownMenuItem(value: 'pra-sejahtera', child: Text("Pra-Sejahtera", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'madya', child: Text("Madya", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: 'mandiri', child: Text("Mandiri", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _statusEkonomi = v as String)),
                          const SizedBox(height: 15),
                          _buildDropdown("Memiliki Jamban?", _memilikiJamban, [
                            const DropdownMenuItem(value: '1', child: Text("ADA", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                            const DropdownMenuItem(value: '0', child: Text("TIDAK ADA", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))),
                          ], (v) => setState(() => _memilikiJamban = v as String)),
                          
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
                              onPressed: _isLoading ? null : _updateKeluarga,
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
             child: const Text("Edit Keluarga", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.save_as_outlined, color: Colors.white, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController ctrl, {bool isNum = false}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: TextFormField(
          controller: ctrl,
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

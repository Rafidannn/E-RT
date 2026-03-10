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
    // Inisialisasi controller pake data yang dibawa dari list
    _noKkCtrl = TextEditingController(text: widget.keluarga['no_kk']?.toString());
    _alamatCtrl = TextEditingController(text: widget.keluarga['alamat_lengkap']?.toString());
    _sumberAirCtrl = TextEditingController(text: widget.keluarga['sumber_air']?.toString());
    _sampahCtrl = TextEditingController(text: widget.keluarga['pengelolaan_sampah']?.toString());

    _statusEkonomi = widget.keluarga['status_ekonomi'] ?? 'pra-sejahtera';
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

      // Pastiin lu udah buat endpoint update_keluarga.php
      final res = await ApiService.post(ApiUrl.updateKeluarga, body);

      if (res['status'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data keluarga berhasil diperbarui"), backgroundColor: Colors.green)
          );
          Navigator.pop(context, true); // Balik ke list sambil bawa sinyal refresh
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
        title: const Text("Edit Data Keluarga", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2D4B1E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInput(_noKkCtrl, "Nomor KK", Icons.badge, isNum: true),
              const SizedBox(height: 15),
              _buildInput(_alamatCtrl, "Alamat Lengkap", Icons.home),
              const SizedBox(height: 15),
              _buildInput(_sumberAirCtrl, "Sumber Air (PDAM/Sumur)", Icons.water_drop),
              const SizedBox(height: 15),
              _buildInput(_sampahCtrl, "Pengelolaan Sampah", Icons.delete_sweep),
              const SizedBox(height: 20),

              const Text("Status Ekonomi", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _statusEkonomi,
                items: ['pra-sejahtera', 'madya', 'mandiri'].map((String value) {
                  return DropdownMenuItem<String>(value: value, child: Text(value.toUpperCase()));
                }).toList(),
                onChanged: (v) => setState(() => _statusEkonomi = v!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              const Text("Memiliki Jamban?", style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _memilikiJamban,
                items: [
                  const DropdownMenuItem(value: '1', child: Text("ADA")),
                  const DropdownMenuItem(value: '0', child: Text("TIDAK ADA")),
                ],
                onChanged: (v) => setState(() => _memilikiJamban = v!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateKeluarga,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D4B1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SIMPAN PERUBAHAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF2D4B1E)),
          border: const OutlineInputBorder()
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi cok" : null,
    );
  }
}
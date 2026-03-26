import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class InputIuranPage extends StatefulWidget {
  const InputIuranPage({super.key});

  @override
  State<InputIuranPage> createState() => _InputIuranPageState();
}

class _InputIuranPageState extends State<InputIuranPage> {
  List<dynamic> _listKeluarga = [];
  String? _selectedIdKeluarga;
  
  String? _selectedJenisIuran;
  String? _selectedPeriode;
  String? _selectedNominal;
  String? _selectedMetode;
  
  final TextEditingController _catatanCtrl = TextEditingController();
  
  bool _isLoadingKeluarga = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchKeluarga();
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchKeluarga() async {
    try {
      final res = await ApiService.get(ApiUrl.getKeluargaIuran);
      if (res['status'] == 'success') {
        setState(() {
          _listKeluarga = res['data'];
          _isLoadingKeluarga = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoadingKeluarga = false);
    }
  }

  Future<void> _simpan() async {
    if (_selectedIdKeluarga == null || _selectedJenisIuran == null || _selectedPeriode == null || _selectedNominal == null || _selectedMetode == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua field wajib!"), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse(ApiUrl.postIuran));
      
      request.fields['id_keluarga'] = _selectedIdKeluarga!;
      request.fields['id_user'] = '1';
      request.fields['jenis_iuran'] = _selectedJenisIuran!;
      request.fields['bulan'] = _selectedPeriode!;
      request.fields['tahun'] = DateTime.now().year.toString();
      request.fields['nominal'] = _selectedNominal!.replaceAll('Rp', '').replaceAll('.', '').trim();
      request.fields['metode_pembayaran'] = _selectedMetode!;
      request.fields['catatan'] = _catatanCtrl.text;

      var response = await request.send();
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final resStr = await response.stream.bytesToString();
        try {
          final resJson = json.decode(resStr);
          if (resJson['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil simpan iuran!"), backgroundColor: Colors.green));
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal dari DB: ${resJson['message']}"), backgroundColor: Colors.red));
          }
        } catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Parsing Error: $resStr"), backgroundColor: Colors.red));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghubungi server!"), backgroundColor: Colors.red));
      }
    } catch (e) {
      debugPrint("Error saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background Dark Green shape
          Positioned(
            top: 0, left: 0, right: 0, bottom: 250,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF334A28),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
              ),
            ),
          ),
          // Logo ERT besar di tengah belakang form
          Positioned(
            top: 300,
            left: 0,
            right: 0,
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
                _buildTabs(),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        children: [
                          _buildKeluargaDropdown(),
                          const SizedBox(height: 15),
                          
                          _buildCustomDropdown(
                            hint: "Jenis Iuran",
                            value: _selectedJenisIuran,
                            items: ["Iuran Sampah/Kebersihan", "Iuran Keamanan", "Iuran Kas RT", "Sumbangan Sukarela"],
                            onChanged: (val) => setState(() => _selectedJenisIuran = val)
                          ),
                          const SizedBox(height: 15),

                          _buildCustomDropdown(
                            hint: "Periode",
                            value: _selectedPeriode,
                            items: ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"],
                            onChanged: (val) => setState(() => _selectedPeriode = val)
                          ),
                          const SizedBox(height: 15),

                          _buildCustomDropdown(
                            hint: "Nominal",
                            value: _selectedNominal,
                            items: ["Rp 20.000", "Rp 50.000", "Rp 100.000"],
                            onChanged: (val) => setState(() => _selectedNominal = val)
                          ),
                          const SizedBox(height: 15),

                          _buildCustomDropdown(
                            hint: "Metode Pembayaran",
                            value: _selectedMetode,
                            items: ["Tunai/Cash", "Transfer Bank", "E-Wallet (OVO/Dana/dll)"],
                            onChanged: (val) => setState(() => _selectedMetode = val)
                          ),
                          const SizedBox(height: 15),

                          Container(
                            height: 120,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: _catatanCtrl,
                              maxLines: 4,
                              style: const TextStyle(color: Colors.black87),
                              decoration: const InputDecoration(
                                hintText: "Catatan :",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 35),
                          _buildSubmitButton(),
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
             child: const Text("Input Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.domain_verification_outlined, color: Colors.white, size: 28),
              onPressed: () {
                Navigator.pushNamed(context, '/verifikasi_pembayaran');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE69138),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.chevron_left, color: Colors.white, size: 16),
              SizedBox(width: 5),
              Text("Input Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 30),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/manage_iuran');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFE69138),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Text("Riwayat Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Icon(Icons.chevron_right, color: Colors.white, size: 16),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildKeluargaDropdown() {
    if (_isLoadingKeluarga) {
       return const Padding(padding: EdgeInsets.all(10), child: Center(child: CircularProgressIndicator(color: Colors.white)));
    }
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedIdKeluarga,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          hint: const Text("No. KK", style: TextStyle(color: Colors.grey, fontSize: 15)),
          items: _listKeluarga.map((k) {
             return DropdownMenuItem<String>(
               value: k['id_keluarga'].toString(),
               child: Text((k['no_kk'] ?? "Keluarga ${k['id_keluarga']}").toString(), style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
             );
          }).toList(),
          onChanged: (val) => setState(() => _selectedIdKeluarga = val),
        ),
      ),
    );
  }

  Widget _buildCustomDropdown({required String hint, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          hint: Text(hint, style: const TextStyle(color: Colors.grey, fontSize: 15)),
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(i, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8BA54D),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
        ),
        onPressed: _isSaving ? null : _simpan,
        child: _isSaving 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Simpan Pembayaran", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

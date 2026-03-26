import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

// --- WIDGET HELPER ---
AppBar _buildSubAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0.5,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3624)),
      onPressed: () => Navigator.pop(context, true), // Return true to trigger refresh
    ),
    title: Text(title, style: const TextStyle(color: Color(0xFF1B3624), fontWeight: FontWeight.bold, fontSize: 16)),
    centerTitle: true,
  );
}

// 1. EDIT PROFIL PAGE
class EditProfilPage extends StatefulWidget {
  final String currentName;
  final String currentNik;

  const EditProfilPage({super.key, required this.currentName, required this.currentNik});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  late TextEditingController _nameController;
  final TextEditingController _nikController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _nikController.text = widget.currentNik; // Disabled NIK
  }

  Future<void> _saveProfil() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post("${ApiUrl.baseUrl}/profil/update_profil.php", {
        "nik": widget.currentNik,
        "nama": _nameController.text
      });

      if (res['status'] == true) {
        // Update local SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('nama_user', _nameController.text);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
           Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSubAppBar(context, "Edit Profil"),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
             TextField(
               controller: _nikController,
               enabled: false,
               decoration: const InputDecoration(labelText: "Username (NIK)", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 20),
             TextField(
               controller: _nameController,
               decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 40),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF1B3624),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                 ),
                 onPressed: _isLoading ? null : _saveProfil,
                 child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Simpan Profil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               ),
             )
          ],
        ),
      ),
    );
  }
}

// 2. UBAH PASSWORD PAGE
class UbahPasswordPage extends StatefulWidget {
  final String currentNik;
  const UbahPasswordPage({super.key, required this.currentNik});

  @override
  State<UbahPasswordPage> createState() => _UbahPasswordPageState();
}

class _UbahPasswordPageState extends State<UbahPasswordPage> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  bool _isLoading = false;

  Future<void> _savePassword() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.post("${ApiUrl.baseUrl}/profil/update_password.php", {
        "nik": widget.currentNik,
        "old_password": _oldController.text,
        "new_password": _newController.text
      });

      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
      if (res['status'] == true && mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSubAppBar(context, "Keamanan & Kata Sandi"),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
             TextField(
               controller: _oldController,
               obscureText: true,
               decoration: const InputDecoration(labelText: "Kata Sandi Lama", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 20),
             TextField(
               controller: _newController,
               obscureText: true,
               decoration: const InputDecoration(labelText: "Kata Sandi Baru", border: OutlineInputBorder()),
             ),
             const SizedBox(height: 40),
             SizedBox(
               width: double.infinity,
               height: 50,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF1B3624),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                 ),
                 onPressed: _isLoading ? null : _savePassword,
                 child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Ganti Kata Sandi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
               ),
             )
          ],
        ),
      ),
    );
  }
}

// 3. PENGATURAN NOTIFIKASI
class PengaturanNotifikasiPage extends StatefulWidget {
  const PengaturanNotifikasiPage({super.key});

  @override
  State<PengaturanNotifikasiPage> createState() => _PengaturanNotifikasiPageState();
}

class _PengaturanNotifikasiPageState extends State<PengaturanNotifikasiPage> {
  bool pushNotif = true;
  bool emailNotif = true;
  bool smsNotif = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSubAppBar(context, "Pengaturan Notifikasi"),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            activeColor: const Color(0xFF1B3624),
            title: const Text("Push Notification Aplikasi", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Pemberitahuan pop-up di layar handphone"),
            value: pushNotif,
            onChanged: (val) => setState(() => pushNotif = val),
          ),
          const Divider(),
          SwitchListTile(
               activeColor: const Color(0xFF1B3624),
            title: const Text("Email Notification", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Tagihan iuran & berita bulanan"),
            value: emailNotif,
            onChanged: (val) => setState(() => emailNotif = val),
          ),
          const Divider(),
          SwitchListTile(
               activeColor: const Color(0xFF1B3624),
            title: const Text("SMS Notification", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Peringatan darurat & keamanan RT"),
            value: smsNotif,
            onChanged: (val) => setState(() => smsNotif = val),
          ),
        ],
      ),
    );
  }
}

// 4. LOG AKTIVITAS (ADMIN)
class LogAktivitasPage extends StatefulWidget {
  const LogAktivitasPage({super.key});

  @override
  State<LogAktivitasPage> createState() => _LogAktivitasPageState();
}

class _LogAktivitasPageState extends State<LogAktivitasPage> {
  List<dynamic> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final res = await ApiService.get("${ApiUrl.baseUrl}/admin/get_logs.php");
      if (res['status'] == true) {
        setState(() => _logs = res['data']);
      }
    } catch (e) {
      debugPrint("Log error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getIcon(String iconStr) {
    if (iconStr == 'wallet') return Icons.account_balance_wallet_outlined;
    if (iconStr == 'person_add') return Icons.person_add_outlined;
    if (iconStr == 'campaign') return Icons.campaign_outlined;
    return Icons.history;
  }

  Color _getColor(String cStr) {
    if (cStr == 'blue') return Colors.blue;
    if (cStr == 'orange') return Colors.orange;
    if (cStr == 'green') return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: _buildSubAppBar(context, "Log Aktivitas Sistem"),
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator())
         : _logs.isEmpty 
             ? const Center(child: Text("Tidak ada log baru"))
             : ListView.builder(
                 padding: const EdgeInsets.all(20),
                 itemCount: _logs.length,
                 itemBuilder: (context, index) {
                   final l = _logs[index];
                   return Container(
                     margin: const EdgeInsets.only(bottom: 12),
                     padding: const EdgeInsets.all(15),
                     decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5)]
                     ),
                     child: Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Container(
                           padding: const EdgeInsets.all(8),
                           decoration: BoxDecoration(
                             color: _getColor(l['color'] ?? '').withValues(alpha: 0.1),
                             shape: BoxShape.circle,
                           ),
                           child: Icon(_getIcon(l['icon'] ?? ''), color: _getColor(l['color'] ?? ''), size: 20),
                         ),
                         const SizedBox(width: 15),
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(l['message'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                               const SizedBox(height: 5),
                               Text(l['time'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                             ],
                           )
                         )
                       ],
                     ),
                   );
                 },
               ),
    );
  }
}

// 5. STATIC SYARAT & KETENTUAN
class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildSubAppBar(context, "Syarat & Ketentuan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Syarat & Ketentuan Penggunaan ERT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B3624))),
            const SizedBox(height: 20),
            const Text("1. Data yang disimpan di sistem ini menjadi tanggung jawab ketua RT setempat.", style: TextStyle(height: 1.5, color: Colors.black87)),
            const SizedBox(height: 10),
            const Text("2. Pengguna wajib menjaga kerahasiaan kata sandi.", style: TextStyle(height: 1.5, color: Colors.black87)),
            const SizedBox(height: 10),
            const Text("3. Pencadangan data hanya dapat dilakukan oleh Kepala / Admin.", style: TextStyle(height: 1.5, color: Colors.black87)),
            const SizedBox(height: 10),
            const Text("4. Pihak Developer (Chancellor Archidal) berhak melakukan penyesuaian server jika diperlukan secara berkala.", style: TextStyle(height: 1.5, color: Colors.black87)),
            const SizedBox(height: 30),
            Center(child: Image.asset('assets/images/logo_ert.png', height: 80, errorBuilder: (c,e,s) => const Icon(Icons.shield_outlined, size: 80, color: Colors.green))),
          ],
        ),
      ),
    );
  }
}

// 6. EXPORT CSV BACKEND INTEGRATION
class AdminTools {
  static Future<void> exportDataCsv(BuildContext context) async {
    // Scaffold showing loading
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyiapkan file data CSV Anda...')));
    
    // We will simulate downloading data to a CSV using what we have in cache
    // Or normally we fetch directly:
    try {
      final res = await ApiService.get(ApiUrl.getWarga); // Grab data warga
      if (res['status'] == true) {
         List<dynamic> data = res['data'];
         
         String csvContent = "ID,NamaLengkap,NIK,JenisKelamin,StatusWarga\n";
         for (var d in data) {
           csvContent += "${d['id_warga']},${d['nama_lengkap']},${d['nik']},${d['jenis_kelamin']},${d['status_warga']}\n";
         }
         
         final dir = await getApplicationDocumentsDirectory();
         final File file = File('${dir.path}/Cadangan_Warga_ERT.csv');
         await file.writeAsString(csvContent);
         
         if (context.mounted) {
           // Provide file to Share
           await Share.shareXFiles([XFile(file.path)], text: 'Berikut pencadangan Data Data Warga RT sistem ERT.');
         }
      } else {
         if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengambil data untuk CSV')));
      }
    } catch(e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error membuat CSV: $e')));
    }
  }

  static void openDevWhatsapp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Akan membuka Whatsapp Developer: +62821...')));
  }
}

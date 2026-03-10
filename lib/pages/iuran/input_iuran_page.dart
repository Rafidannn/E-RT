import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RiwayatIuranPage extends StatefulWidget {
  const RiwayatIuranPage({super.key});

  @override
  State<RiwayatIuranPage> createState() => _RiwayatIuranPageState();
}

class _RiwayatIuranPageState extends State<RiwayatIuranPage> {
  // Fungsi ambil data dari database lewat API
  Future<List> _fetchRiwayat() async {
    try {
      final res = await ApiService.get(ApiUrl.getRekapIuran);
      // Pastikan response API lu punya key 'data'
      return res['data'] ?? [];
    } catch (e) {
      debugPrint("Error Fetching: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
            "Riwayat Iuran",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        backgroundColor: const Color(0xFF2D4B1E),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List>(
        future: _fetchRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2D4B1E)));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data iuran."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final item = snapshot.data![i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF8CAF5D),
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text(
                      "Warga ID: ${item['id_keluarga']}",
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text("${item['jenis_iuran']} - ${item['bulan']} ${item['tahun']}"),
                  trailing: Text(
                    "Rp ${item['nominal']}",
                    style: const TextStyle(
                        color: Color(0xFF2D4B1E),
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
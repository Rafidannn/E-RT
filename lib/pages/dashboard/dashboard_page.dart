import 'package:flutter/material.dart';
import '../../widgets/app_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard E-RT')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Statistik Wilayah', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: AppCard(title: 'Warga', value: '150', icon: Icons.people, color: Colors.blue)),
                Expanded(child: AppCard(title: 'Iuran', value: 'Lunas', icon: Icons.money, color: Colors.green)),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Pengumuman', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // Nanti di sini pakai ListView buat ambil data dari API pengumuman
            const ListTile(
              leading: Icon(Icons.campaign, color: Colors.orange),
              title: Text('Kerja Bakti Hari Minggu'),
              subtitle: Text('Jam 07:00 di Lapangan'),
            ),
          ],
        ),
      ),
    );
  }
}
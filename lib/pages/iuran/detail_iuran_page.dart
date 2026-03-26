import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/api_url.dart';

class DetailIuranPage extends StatefulWidget {
  final dynamic item;
  const DetailIuranPage({super.key, required this.item});

  @override
  State<DetailIuranPage> createState() => _DetailIuranPageState();
}

class _DetailIuranPageState extends State<DetailIuranPage> {
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isProcessing = false;

  void _shareReceipt() async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/resi_iuran_${widget.item['transaction_id'] ?? '123'}.png').create();
        await imagePath.writeAsBytes(image);
        await Share.shareXFiles([XFile(imagePath.path)], text: 'Berikut adalah resi pembayaran iuran saya.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membagikan: $e")));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _unduhResi() async {
    setState(() => _isProcessing = true);
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        // Because downloading to gallery natively requires different approaches per platform,
        // using Share dialog with 'Save Image' is the most robust cross-platform way without extra permissions setups.
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/resi_iuran_${widget.item['transaction_id'] ?? '123'}.png').create();
        await imagePath.writeAsBytes(image);
        await Share.shareXFiles([XFile(imagePath.path)], text: 'Simpan resi ini');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pilih 'Simpan ke Perangkat' di menu bagikan.")));
        }
      }
    } catch (e) {
      //
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = widget.item['status'].toString().toLowerCase();
    Color statusColor = status == 'lunas' ? Colors.green : (status == 'pending' ? Colors.orange : Colors.red);
    String topText = status == 'lunas' ? "Pembayaran Berhasil" : (status == 'pending' ? "Menunggu Konfirmasi" : "Pembayaran Ditolak");
    IconData topIcon = status == 'lunas' ? Icons.check : (status == 'pending' ? Icons.schedule : Icons.close);
    Color topIconBg1 = status == 'lunas' ? Colors.orange : (status == 'pending' ? Colors.orangeAccent : Colors.redAccent);
    Color topIconBg2 = status == 'lunas' ? Colors.deepOrange : (status == 'pending' ? Colors.deepOrangeAccent : Colors.red);
    String namaKepala = widget.item['nama_kepala'] ?? "NN";
    String noKk = widget.item['no_kk'] ?? "-";

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Stack(
        children: [
          // Background Top Green Shape
          Container(
            height: 380,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28), // Dark Green
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: IconButton(
                          iconSize: 20,
                          padding: const EdgeInsets.all(5),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF759A3D),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text("Detail Iuran", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 15),
                        child: Icon(Icons.person_add_alt_1_outlined, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Wrap the receipt part in Screenshot widget
                        Screenshot(
                          controller: screenshotController,
                          child: Container(
                            color: Colors.transparent, // Background wrapper
                            child: Stack(
                              children: [
                                // Need to draw a green background for the screenshot so it looks right
                                Positioned.fill(
                                  bottom: 100, // Make sure it only covers top
                                  child: Container(
                                    color: const Color(0xFF334A28),
                                  ),
                                ),
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    // Status Header
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [topIconBg1, topIconBg2]),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(topIcon, color: Colors.white, size: 30),
                                    ),
                                    const SizedBox(height: 15),
                                    const Text("STATUS TRANSAKSI", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                                    const SizedBox(height: 5),
                                    Text(topText, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Text("Rp ${_formatCurrency(int.parse(widget.item['nominal'].toString()))}", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                                    const SizedBox(height: 25),

                                    // White Receipt Card
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(horizontal: 20),
                                      padding: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: const Border(top: BorderSide(color: Colors.greenAccent, width: 4)),
                                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("JENIS IURAN", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                          const SizedBox(height: 5),
                                          Text(widget.item['jenis_iuran'] ?? "Iuran Warga", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black87)),

                                          const SizedBox(height: 25),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text("PERIODE", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                                  const SizedBox(height: 5),
                                                  Text("${widget.item['bulan']} ${widget.item['tahun']}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text("TANGGAL", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                                  const SizedBox(height: 5),
                                                  Text(widget.item['tanggal_bayar'] ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                                ],
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 25),
                                          const Text("TRANSACTION ID", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(color: const Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(5)),
                                            child: Text(widget.item['transaction_id'] ?? "#TRX-PENDING", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                                          ),

                                          const SizedBox(height: 25),
                                          _buildDashedLine(),
                                          const SizedBox(height: 20),

                                          const Text("DETAIL PEMBAYAR", style: TextStyle(color: Color(0xFF28864B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                          const SizedBox(height: 15),
                                          _buildDetailRow("Kepala Keluarga", namaKepala),
                                          _buildDetailRow("Nomor KK", noKk),
                                          _buildDetailRow("Metode", widget.item['metode_pembayaran'] ?? "-"),

                                          const SizedBox(height: 20),
                                          const Text("BUKTI TRANSFER", style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                                          const SizedBox(height: 10),
                                          Container(
                                            height: 100, width: 100,
                                            decoration: BoxDecoration(
                                                color: Colors.orange.shade50,
                                                borderRadius: BorderRadius.circular(15),
                                                image: widget.item['bukti_transfer'] != null && widget.item['bukti_transfer'].toString().isNotEmpty
                                                    ? DecorationImage(image: NetworkImage(ApiUrl.baseUrl + "/iuran/" + widget.item['bukti_transfer']), fit: BoxFit.cover)
                                                    : null
                                            ),
                                            child: widget.item['bukti_transfer'] == null || widget.item['bukti_transfer'] == "" ? const Icon(Icons.image, color: Colors.orange) : null,
                                          ),

                                          const SizedBox(height: 25),
                                          _buildDottedLine(),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(color: const Color(0xFFCCEFD9), shape: BoxShape.circle),
                                                child: const Icon(Icons.security, color: Color(0xFF28864B), size: 16),
                                              ),
                                              const SizedBox(width: 15),
                                              const Expanded(child: Text("Diterima oleh Bendahara RT 05\nSistem Digital Terverifikasi", style: TextStyle(fontSize: 10, color: Colors.black54, height: 1.4))),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Buttons (outside screenshot)
                        const SizedBox(height: 30),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF334A28),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              icon: _isProcessing
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Icon(Icons.download, color: Colors.white, size: 20),
                              label: Text(_isProcessing ? "MEMPROSES..." : "UNDUH RESI (PDF/JPG)", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                              onPressed: _isProcessing ? null : _unduhResi,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextButton.icon(
                            onPressed: _isProcessing ? null : _shareReceipt,
                            icon: const Icon(Icons.share, color: Color(0xFF28864B), size: 20),
                            label: const Text("BAGIKAN", style: TextStyle(color: Color(0xFF28864B), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1))
                        ),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE5E5E5))),
            );
          }),
        );
      },
    );
  }

  Widget _buildDottedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 3.0;
        const dashHeight = 1.5;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFD9D9D9))),
            );
          }),
        );
      },
    );
  }

  String _formatCurrency(int amount) {
    String result = "";
    String amountStr = amount.toString();
    int count = 0;
    for (int i = amountStr.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        result = ".$result";
      }
      result = amountStr[i] + result;
      count++;
    }
    return result;
  }
}

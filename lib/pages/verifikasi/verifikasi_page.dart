import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class VerifikasiPage extends StatefulWidget {
  const VerifikasiPage({super.key});

  @override
  State<VerifikasiPage> createState() => _VerifikasiPageState();
}

class _VerifikasiPageState extends State<VerifikasiPage> {
  List<dynamic> _listPending = [];
  bool _isLoading = true;
  
  // Nyimpen state dropdown role untuk tiap user: key = id_user
  final Map<String, String> _selectedRoles = {};
  final List<String> _roleOptions = ['warga', 'admin', 'posyandu', 'jumantik', 'kader_dawis'];

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiUrl.getPendingUsers);
      if (res['status'] == 'success') {
        setState(() {
          _listPending = res['data'] ?? [];
          for (var item in _listPending) {
            String idStr = item['id_user'].toString();
            if (!_selectedRoles.containsKey(idStr)) {
               _selectedRoles[idStr] = item['role_saat_ini'] ?? 'warga';
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal load pending user: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAction(String idUser, String action) async {
    try {
      String roleToAssign = _selectedRoles[idUser] ?? 'warga';
      final res = await ApiService.post(ApiUrl.verifyUser, {
        'id_user': idUser,
        'action': action,
        'role': roleToAssign
      });
      
      if (res['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']), backgroundColor: action == 'terima' ? Colors.green : Colors.red),
        );
        _fetchPendingUsers(); // Reload lists
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message']), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Terjadi kesalahan: $e"), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // Background ERT Logo
          Positioned(
            top: 250,
            left: 0,
            right: 0,
            child: Center(
              child: Opacity(
                opacity: 0.6,
                child: Image.asset('assets/images/logo_ert.png', width: 220, fit: BoxFit.contain),
              ),
            ),
          ),

          // Green Header Base
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF334A28),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              )
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoading 
                    ? const Center(child: CircularProgressIndicator())
                    : _listPending.isEmpty
                        ? _buildEmptyState()
                        : _buildUserList(),
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
             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
             decoration: BoxDecoration(
                color: const Color(0xFF8BA54D),
                borderRadius: BorderRadius.circular(20),
             ),
             child: const Text("Verifikasi User", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.person_add_outlined, color: Colors.white, size: 28),
              onPressed: _fetchPendingUsers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            color: const Color(0xFFE69138),
            child: const Text(
              "Belum ada Pengguna baru mendaftar",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 40, left: 20, right: 20),
      itemCount: _listPending.length,
      itemBuilder: (context, index) {
        final item = _listPending[index];
        bool terdaftar = item['status_daftar'] == 'Terdaftar';
        String idStr = item['id_user'].toString();
        
        String init = item['nama_lengkap'].toString().isNotEmpty ? item['nama_lengkap'].toString().substring(0, 1).toUpperCase() : 'U';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
               BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 5))
            ]
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Color(0xFF8BA54D),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(init, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nama Lengkap : ${item['nama_lengkap']}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Text("Nik : ${item['nik']}", style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                             color: terdaftar ? const Color(0xFF334A28) : const Color(0xFFE69138),
                             borderRadius: BorderRadius.circular(5)
                          ),
                          child: Text(item['status_daftar'] ?? 'T. Terdaftar', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Waktu Daftar : ${item['waktu_daftar']}", style: const TextStyle(fontSize: 12)),
                    
                    const SizedBox(height: 4),
                    Row(
                      children: [
                         const Text("Pilihan Role : ", style: TextStyle(fontSize: 12)),
                         Expanded(
                           child: Container(
                             height: 25,
                             padding: const EdgeInsets.symmetric(horizontal: 5),
                             decoration: const BoxDecoration(
                               border: Border(bottom: BorderSide(color: Colors.grey, width: 1))
                             ),
                             child: DropdownButtonHideUnderline(
                               child: DropdownButton<String>(
                                 isExpanded: true,
                                 value: _selectedRoles[idStr],
                                 icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                                 style: const TextStyle(fontSize: 12, color: Colors.black),
                                 items: _roleOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                 onChanged: (val) {
                                   if(val != null) setState(() => _selectedRoles[idStr] = val);
                                 },
                               ),
                             ),
                           )
                         )
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Button Tolak
                        GestureDetector(
                          onTap: () => _verifyAction(idStr, 'tolak'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB32025),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Row(
                              children: [
                                Text("Tolak", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Icon(Icons.close, color: Colors.white, size: 14)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Button Terima
                        GestureDetector(
                          onTap: () => _verifyAction(idStr, 'terima'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF334A28),
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: const Row(
                              children: [
                                Text("Terima", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Icon(Icons.check, color: Colors.white, size: 14)
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              )
            ],
          ),
        );
      },
    );
  }
}

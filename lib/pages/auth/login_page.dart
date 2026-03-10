import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT INI
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_nikController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIK dan Password tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.post(ApiUrl.login, {
        'nik': _nikController.text,
        'password': _passwordController.text,
      });

      if (response['status'] == true || response['status'] == 'success') {
        // SIMPAN SESSION USER
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // Ambil data user dari response API lu (sesuaikan key 'nama' & 'role')
        String nama = response['data']['nama'] ?? 'User';
        String role = response['data']['role'] ?? 'warga';

        await prefs.setString('nama_user', nama);
        await prefs.setString('role', role);

        if (!mounted) return;

        // LOGIKA PINDAH DASHBOARD BERDASARKAN ROLE
        if (role.toLowerCase() == 'admin') {
          Navigator.pushReplacementNamed(context, '/dashboard_admin');
        } else {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login Gagal')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.35,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/logo_ert.png',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 80),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF618F3C),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.65),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4B1E),
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(80)),
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Login', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'RobotoBlack')),
                      const Text('Login to get your account', style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'RobotoMedium')),
                      const SizedBox(height: 40),
                      _buildInput(controller: _nikController, hint: 'Enter your NIK', icon: Icons.assignment_ind_outlined),
                      const SizedBox(height: 20),
                      _buildInput(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Login', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'RobotoBlack')),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white38)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(context, '/register'),
                              child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontFamily: 'RobotoMedium',
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.orange,
                                    decorationThickness: 2,
                                  )
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white38)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(fontFamily: 'RobotoMedium', color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'RobotoMedium', color: Colors.grey),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    );
  }
}
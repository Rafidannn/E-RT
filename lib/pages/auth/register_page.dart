import 'package:flutter/material.dart';
import '../../core/api/api_service.dart';
import '../../core/constants/api_url.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _selectedRole;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    // Validasi sederhana
    if (_nameController.text.isEmpty || _nikController.text.isEmpty ||
        _passwordController.text.isEmpty || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi semua datanya dulu bos!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Pastiin endpoint ApiUrl.register udah lu setting di constants
      final response = await ApiService.post(ApiUrl.register, {
        'nama': _nameController.text,
        'nik': _nikController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
      });

      if (response['status'] == true || response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal daftar nih')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
            // LOGO AREA
            Container(
              height: screenHeight * 0.3,
              width: double.infinity,
              color: Colors.white,
              child: Center(
                child: Image.asset(
                  'assets/images/logo_ert.png',
                  height: 160,
                ),
              ),
            ),

            // FORM AREA - ROUNDED KANAN
            Stack(
              children: [
                // LAYER 1: IJO MUDA (Back)
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF618F3C),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(80)),
                  ),
                ),

                // LAYER 2: IJO TUA (Main)
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4B1E),
                    borderRadius: BorderRadius.only(topRight: Radius.circular(80)),
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, -5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, fontFamily: 'RobotoBlack')),
                      const Text('Sign In to get your account', style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'RobotoMedium')),
                      const SizedBox(height: 30),

                      _buildInput(controller: _nameController, hint: 'Enter your Full Name', icon: Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildInput(controller: _nikController, hint: 'Enter your Nik', icon: Icons.assignment_ind_outlined),
                      const SizedBox(height: 20),
                      _buildInput(controller: _passwordController, hint: 'Password', icon: Icons.lock_outline, isPassword: true),
                      const SizedBox(height: 20),

                      _buildDropdown(),
                      const SizedBox(height: 30),

                      // TOMBOL SIGN UP
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sign Up', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'RobotoBlack')),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // FOOTER NAVIGASI
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white38)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(context, '/login'),
                              child: const Text("or", style: TextStyle(color: Colors.white, fontFamily: 'RobotoMedium', decoration: TextDecoration.underline, decorationColor: Colors.blue, decorationThickness: 2)),
                            ),
                          ),
                          const Expanded(child: Divider(color: Colors.white38)),
                        ],
                      ),
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: const Color(0xFFF3F3F3), borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: const Text('Choose your Role', style: TextStyle(color: Colors.grey, fontFamily: 'RobotoMedium')),
          isExpanded: true,
          items: <String>['Warga', 'Ketua RT', 'Admin'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value, style: const TextStyle(fontFamily: 'RobotoMedium')));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedRole = newValue),
        ),
      ),
    );
  }
}

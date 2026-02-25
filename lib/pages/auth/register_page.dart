import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // BAGIAN LOGO (PUTIH)
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

            // BAGIAN FORM DENGAN TERTUMPUK (STACK) - ROUNDED KANAN
            Stack(
              children: [
                // LAYER 1: IJO MUDA (Aksen di Belakang - Rounded Kanan)
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Color(0xFF618F3C),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(80), // PINDAH KE KANAN
                    ),
                  ),
                ),

                // LAYER 2: IJO TUA (Konten Utama - Rounded Kanan)
                Container(
                  margin: const EdgeInsets.only(top: 15),
                  width: double.infinity,
                  constraints: BoxConstraints(minHeight: screenHeight * 0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D4B1E),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(80), // PINDAH KE KANAN
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 15,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'RobotoBlack',
                        ),
                      ),
                      const Text(
                        'Sign In to get your account',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'RobotoMedium',
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Input Full Name
                      _buildInput(
                        controller: _nameController,
                        hint: 'Enter your Full Name',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),

                      // Input NIK
                      _buildInput(
                        controller: _nikController,
                        hint: 'Enter your Nik',
                        icon: Icons.assignment_ind_outlined,
                      ),
                      const SizedBox(height: 20),

                      // Input Password
                      _buildInput(
                        controller: _passwordController,
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),

                      // Dropdown Choose Role
                      _buildDropdown(),

                      const SizedBox(height: 20),

                      // Remember me
                      Row(
                        children: [
                          const Icon(Icons.check_box, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                              'Remember me',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'RobotoMedium',
                              )
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Tombol Sign Up
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'RobotoBlack',
                              )
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Footer "or" pindah ke login
                      Row(
                        children: [
                          const Expanded(child: Divider(color: Colors.white38)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: const Text(
                                "or",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontFamily: 'RobotoMedium',
                                ),
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
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRole,
          hint: const Text('Choose your Role', style: TextStyle(color: Colors.grey, fontFamily: 'RobotoMedium')),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: <String>['Warga', 'Ketua RT', 'Admin'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontFamily: 'RobotoMedium')),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
      ),
    );
  }
}
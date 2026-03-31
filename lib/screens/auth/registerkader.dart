import 'package:flutter/material.dart';
import 'package:sijentik/controller/register_controller.dart';

class RegisterKaderPage extends StatefulWidget {
  const RegisterKaderPage({super.key});

  @override
  State<RegisterKaderPage> createState() => _RegisterKaderPageState();
}

class _RegisterKaderPageState extends State<RegisterKaderPage> {
  late final RegisterKaderController controller;

  @override
  void initState() {
    super.initState();
    controller = RegisterKaderController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await controller.register();

    if (!mounted) return;

    final message = result.success
        ? result.message
        : controller.getErrorMessage(result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    if (result.success) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: 30,
                      left: 24,
                      right: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF206E97),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.maybePop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 25,
                            ),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                        const Text(
                          'DAFTAR',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextFieldWithIcon(
                            label: 'Nama',
                            hint: 'Masukkan nama lengkap',
                            controller: controller.namaController,
                            icon: Icons.person_outline,
                            validator: controller.validateNama,
                          ),
                          const SizedBox(height: 20),

                          _buildTextFieldWithIcon(
                            label: 'Email',
                            hint: 'email@gmail.com',
                            controller: controller.emailController,
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.email_outlined,
                            validator: controller.validateEmail,
                          ),
                          const SizedBox(height: 20),

                          _buildTextFieldWithIcon(
                            label: 'Alamat',
                            hint: 'Masukkan alamat lengkap',
                            controller: controller.alamatController,
                            icon: Icons.home_outlined,
                            validator: controller.validateAlamat,
                          ),
                          const SizedBox(height: 20),

                          _buildTextFieldWithIcon(
                            label: 'RT/RW',
                            hint: 'Contoh: 001/002',
                            controller: controller.rtrwController,
                            icon: Icons.format_list_numbered,
                            keyboardType: TextInputType.text,
                            validator: controller.validateRtRw,
                          ),
                          const SizedBox(height: 20),

                          _buildPasswordFieldWithIcon(
                            label: 'Kata Sandi',
                            hint: 'Masukkan kata sandi',
                            controller: controller.passwordController,
                            obscureText: controller.obscurePassword,
                            icon: Icons.lock_outline,
                            onToggleVisibility: controller.togglePassword,
                            validator: controller.validatePassword,
                          ),
                          const SizedBox(height: 20),

                          _buildPasswordFieldWithIcon(
                            label: 'Konfirmasi Kata Sandi',
                            hint: 'Masukkan konfirmasi kata sandi',
                            controller: controller.konfirmasiPasswordController,
                            obscureText: controller.obscureKonfirmasiPassword,
                            icon: Icons.lock_outline,
                            onToggleVisibility:
                                controller.toggleKonfirmasiPassword,
                            validator: controller.validateKonfirmasiPassword,
                          ),
                          const SizedBox(height: 40),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: controller.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF206E97),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextFieldWithIcon({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF206E97),
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordFieldWithIcon({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required IconData icon,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF206E97),
                width: 1.5,
              ),
            ),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey[600],
                size: 20,
              ),
              onPressed: onToggleVisibility,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
        ),
      ],
    );
  }
}

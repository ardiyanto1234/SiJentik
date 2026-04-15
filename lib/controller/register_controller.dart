import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sijentik/api/api.dart';

class RegisterResult {
  final bool success;
  final String message;

  RegisterResult({required this.success, required this.message});
}

class RegisterKaderController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final alamatController = TextEditingController();
  final rtrwController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureKonfirmasiPassword = true;
  bool isLoading = false;

  void togglePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleKonfirmasiPassword() {
    obscureKonfirmasiPassword = !obscureKonfirmasiPassword;
    notifyListeners();
  }

  String? validateNama(String? value) {
    if (value == null || value.isEmpty) {
      return "Nama wajib diisi";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email wajib diisi";
    }

    if (!value.contains("@")) {
      return "Format email tidak valid";
    }

    return null;
  }

  String? validateAlamat(String? value) {
    if (value == null || value.isEmpty) {
      return "Alamat wajib diisi";
    }
    return null;
  }

  String? validateRtRw(String? value) {
    if (value == null || value.isEmpty) {
      return "RT/RW wajib diisi";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password minimal 6 karakter";
    }
    return null;
  }

  String? validateKonfirmasiPassword(String? value) {
    if (value != passwordController.text) {
      return "Password tidak sama";
    }
    return null;
  }

  Future<RegisterResult> register() async {
    if (!formKey.currentState!.validate()) {
      return RegisterResult(success: false, message: "Form belum lengkap");
    }

    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'), // 🔥 pakai baseUrl global
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": namaController.text,
          "email": emailController.text,
          "address": alamatController.text,
          "rtrw": rtrwController.text,
          "password": passwordController.text,
          "password_confirmation": konfirmasiPasswordController.text,
        }),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return RegisterResult(
          success: true,
          message: data["message"] ?? "Register berhasil",
        );
      } else {
        return RegisterResult(
          success: false,
          message: data["message"] ?? data["error"] ?? "Register gagal",
        );
      }
    } catch (e) {
      return RegisterResult(
        success: false,
        message: "Tidak dapat terhubung ke server",
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String getErrorMessage(RegisterResult result) {
    return result.message;
  }

  void dispose() {
    namaController.dispose();
    emailController.dispose();
    alamatController.dispose();
    rtrwController.dispose();
    passwordController.dispose();
    konfirmasiPasswordController.dispose();
    super.dispose();
  }
}

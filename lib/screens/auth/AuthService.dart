import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? errors;

  RegisterResult({
    required this.success,
    required this.message,
    this.errors,
  });
}

class AuthService {
  // Android Emulator => 10.0.2.2
  // HP fisik => ganti dengan IP laptop/PC, misalnya 192.168.1.10
  static const String baseUrl = 'http://192.168.1.6:8000';

  Future<RegisterResult> registerKader({
    required String name,
    required String email,
    required String address,
    required String rtrw,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'address': address,
          'rtrw': rtrw,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      final Map<String, dynamic> data = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {};

      if (response.statusCode == 201) {
        return RegisterResult(
          success: true,
          message: data['message'] ?? 'Register berhasil',
        );
      }

      if (response.statusCode == 422) {
        return RegisterResult(
          success: false,
          message: data['message'] ?? 'Validasi gagal',
          errors: data['errors'],
        );
      }

      return RegisterResult(
        success: false,
        message: data['message'] ?? 'Terjadi kesalahan server',
      );
    } catch (e) {
      return RegisterResult(
        success: false,
        message: 'Gagal terhubung ke server: $e',
      );
    }
  }
}
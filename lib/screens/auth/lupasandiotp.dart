import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'buatsandibaru.dart';

class LupaKataSandiOtpPage extends StatefulWidget {
  final String email;

  const LupaKataSandiOtpPage({super.key, required this.email});

  @override
  State<LupaKataSandiOtpPage> createState() => _LupaKataSandiOtpPageState();
}

class _LupaKataSandiOtpPageState extends State<LupaKataSandiOtpPage> {
  static const int otpLength = 5;

  final List<TextEditingController> otpControllers = List.generate(
    otpLength,
    (index) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(
    otpLength,
    (index) => FocusNode(),
  );

  // Android Emulator: 10.0.2.2
  // HP Fisik: ganti dengan IP laptop, misalnya 192.168.1.8
  static const String verifyOtpUrl = 'http://192.168.1.6:8000/api/verify-otp';
  static const String requestOtpUrl = 'http://192.168.1.6:8000/api/RequestOtp';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(otpFocusNodes[0]);
      }
    });
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),

                const SizedBox(height: 20),

                Image.asset('assets/images/sandi.png', width: 150),

                const SizedBox(height: 20),

                const Text(
                  'KODE OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'Kode telah dikirim ke alamat email Anda:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF206E97),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Silakan masukkan kode OTP yang diterima.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(otpLength, (index) {
                          return SizedBox(
                            width: 50,
                            height: 60,
                            child: TextField(
                              controller: otpControllers[index],
                              focusNode: otpFocusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.0,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF206E97),
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                _handleOtpInput(index, value);
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            _verifikasiOtp();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF206E97),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: const Text(
                            'Verifikasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tidak menerima kode? ',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _kirimUlangOtp();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Kirim ulang',
                              style: TextStyle(
                                color: Color(0xFF1E88E5),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleOtpInput(int index, String value) {
    if (value.isNotEmpty) {
      if (index < otpLength - 1) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
          }
        });
      } else {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            otpFocusNodes[index].unfocus();
          }
        });
      }
    } else {
      if (index > 0) {
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
          }
        });
      }
    }
  }

  String _getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  void _clearOtpFields() {
    for (var controller in otpControllers) {
      controller.clear();
    }
  }

  Future<void> _verifikasiOtp() async {
    final String otpCode = _getOtpCode();

    if (otpCode.length != otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap masukkan semua $otpLength digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memverifikasi OTP...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(verifyOtpUrl),
        headers: {'Accept': 'application/json'},
        body: {'email': widget.email, 'otp': otpCode},
      );

      final dynamic data = jsonDecode(response.body);

      if (!mounted) return;

      Navigator.pop(context);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'OTP berhasil diverifikasi',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuatKataSandiBaruPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ??
                  data['error'] ??
                  'Kode OTP salah atau tidak valid',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _kirimUlangOtp() async {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Mengirim ulang OTP ke ${widget.email}...'),
          ],
        ),
      ),
    );

    try {
      final response = await http.post(
        Uri.parse(requestOtpUrl),
        headers: {'Accept': 'application/json'},
        body: {'email': widget.email, 'type': 'email'},
      );

      final dynamic data = jsonDecode(response.body);

      if (!mounted) return;

      Navigator.pop(context);

      if (response.statusCode == 200) {
        _clearOtpFields();
        FocusScope.of(context).requestFocus(otpFocusNodes[0]);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? 'OTP telah dikirim ulang',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message'] ?? data['error'] ?? 'Gagal mengirim ulang OTP',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan koneksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

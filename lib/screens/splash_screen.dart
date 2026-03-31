import 'dart:async';
import 'package:flutter/material.dart';
import 'auth/login.dart';
import 'package:sijentik/component/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final double topLogoOffset = 90; // jarak dari atas ke logo
  final double betweenLogoAndIllustration = 0; // jarak logo ke ilustrasi
  final double textBottomOffset = 200; // jarak teks dari area bawah (plus safe area)
  final double illustrationOffset = 50; // positif = naikkan ilustrasi

  @override
  void initState() {
    super.initState();
    
    // PASTIKAN NAVIGASI SETELAH WIDGET DIBUAT
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: topLogoOffset),
            Image.asset(
              'assets/images/logo.png',
              width: 180,
            ),
            SizedBox(height: betweenLogoAndIllustration),
            Flexible(
              fit: FlexFit.loose,
              child: Center(
                child: Transform.translate(
                  offset: Offset(0, -illustrationOffset),
                  child: Image.asset(
                    'assets/images/splashscreen.png',
                    width: 350,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(52, 0, 52, MediaQuery.of(context).padding.bottom + textBottomOffset),
              child: Text(
                'Sistem Informasi Pemantauan Jentik Nyamuk',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
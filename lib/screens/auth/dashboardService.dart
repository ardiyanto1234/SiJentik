import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DashboardService {
  static const String baseUrl = "http://192.168.1.6:8000/api";
  // kalau pakai HP asli ganti ke IP laptop, misalnya:
  // static const String baseUrl = "http://192.168.1.8:8000/api";

  static Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final url = Uri.parse("$baseUrl/dashboard-petugas");

      debugPrint("GET DASHBOARD => $url");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
        },
      );

      debugPrint("STATUS CODE => ${response.statusCode}");
      debugPrint("BODY => ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      }

      return null;
    } catch (e) {
      debugPrint("DASHBOARD ERROR => $e");
      return null;
    }
  }
}
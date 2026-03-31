import 'dart:convert';
import 'package:http/http.dart' as http;

class KaderService {

  final String baseUrl = "http://192.168.1.6:8000/api";

  Future<bool> approveKader(int id) async {
    try {

      final response = await http.post(
        Uri.parse("$baseUrl/kader/approve/$id"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;

    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectKader(int id) async {
    try {

      final response = await http.post(
        Uri.parse("$baseUrl/kader/reject/$id"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      return false;

    } catch (e) {
      return false;
    }
  }

}
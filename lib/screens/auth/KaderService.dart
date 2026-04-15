import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sijentik/api/api.dart';

class KaderService {

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
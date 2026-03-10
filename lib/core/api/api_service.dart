import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Buat debugPrint

class ApiService {
  static Future<dynamic> get(String endpoint) async {
    try {
      // TAMBAHIN PRINT INI BIAR KITA TAU DIA NEMBAK MANA
      debugPrint("Mencoba akses: $endpoint");

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      );

      debugPrint("Hasil Body: ${response.body}");
      return _handleResponse(response);
    } catch (e) {
      // PRINT ERROR ASLINYA BIAR KELIATAN DI TERMINAL
      debugPrint("LOG ERROR ASLI: $e");
      throw Exception('Gagal nyambung ke server (GET): $e');
    }
  }

  // ... (Fungsi POST & _handleResponse tetep sama kayak punya lu) ...
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("LOG ERROR POST: $e");
      throw Exception('Gagal nyambung ke server (POST): $e');
    }
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
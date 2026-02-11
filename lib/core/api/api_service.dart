import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fungsi GET
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Accept': 'application/json',
        },
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal nyambung ke server (GET): $e');
    }
  }

  // Fungsi POST
  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
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
      throw Exception('Gagal nyambung ke server (POST): $e');
    }
  }

  // Helper biar nggak nulis if-else berulang-ulang
  static dynamic _handleResponse(http.Response response) {
    // Nerima status code 200 sampe 299 (Success range)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      // Keluarin body error-nya biar lu tau salahnya di mana
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
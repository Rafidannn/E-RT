import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_url.dart';

class ApiService {
  static Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('GET Error: ${response.statusCode}');
    }
  }

  static Future<dynamic> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('POST Error: ${response.statusCode}');
    }
  }
}

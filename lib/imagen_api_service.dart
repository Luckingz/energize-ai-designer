import 'dart:convert';
import 'package:http/http.dart' as http;

//API = AIzaSyAxdzdNeNJzIA72bY4x2S1R0p7LiN4_rpY

// https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=AIzaSyAxdzdNeNJzIA72bY4x2S1R0p7LiN4_rpY"

class ImagenApiService {
  final String apiKey;

  ImagenApiService({required this.apiKey});

  Future<Map<String, dynamic>> generateImage(String prompt) async {
    final url = Uri.parse('https:///v1/images:generate');

    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'prompt': prompt,
      // Add other parameters as needed (e.g., style, size)
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate image: ${response.statusCode}');
    }
  }
}

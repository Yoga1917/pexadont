import 'package:http/http.dart' as http;
import 'dart:convert';

class FcmService {
  static const String apiUrl = 'http://YOUR_API_URL/api/warga/simpanToken';

  // Fungsi untuk kirim token ke API
  static Future<void> saveTokenToApi(String token) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'token': token}),
    );

    if (response.statusCode == 200) {
      print('Token saved successfully');
    } else {
      print('Failed to save token');
    }
  }
}

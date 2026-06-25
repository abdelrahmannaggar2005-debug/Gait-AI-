import 'package:http/http.dart' as http;
import 'dart:convert';

class FogApi {
  final String baseUrl;

  FogApi({required this.baseUrl});

  Future<double> predict(List<List<double>> window) async {
    final response = await http.post(
      Uri.parse('$baseUrl/predict'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'input': window}),
    ).timeout(const Duration(seconds: 2));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['prediction'].toDouble();
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
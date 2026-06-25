import 'package:http/http.dart' as http;
import 'dart:convert';

class FallRiskApi {
  final String baseUrl;
  FallRiskApi({required this.baseUrl});

  Future<double> predictRisk(List<double> features) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict_fall'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'features': features}),
      ).timeout(const Duration(seconds: 10)); // زيادة المهلة إلى 10 ثوانٍ

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['risk'].toDouble();
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
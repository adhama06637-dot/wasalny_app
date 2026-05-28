import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // رابط السيرفر بتاعك اللي شغال 100%
  static const String baseUrl = "https://wasalny-phi.vercel.app";

  // دالة المقارنة اللي بتجيب الأسرع والأرخص والرايد شيرينج مع بعض
  static Future<Map<String, dynamic>> getCompareRoutes(String start, String end) async {
    try {
      final uri = Uri.parse('$baseUrl/compare').replace(
        queryParameters: {
          'start': start,
          'end': end,
          'gender': 'any', // عشان يجيب كل عربيات فايربيز
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': 'Server Error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': 'Connection Failed: $e'};
    }
  }

  // دالة لجلب المحطات لو هتحتاجوها بعدين
  static Future<List<String>> getStations() async {
    try {
      final uri = Uri.parse('$baseUrl/stations');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> stationsList = data['stations'];
        return stationsList.map((s) => s.toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
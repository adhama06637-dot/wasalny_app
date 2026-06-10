import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking.dart';
import '../models/route.dart' as app_route;
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://wasalny-phi.vercel.app';
  String? token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // 🚀 الحل البيرفكت: الاعتماد الكلي على الـ API
  static Future<List<String>> getStations() async {
    try {
      // الـ timeout 10 ثواني عشان سيرفرات Vercel المجانية
      final response = await http.get(Uri.parse('$baseUrl/stations')).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // لو الباك إند باعت الداتا على شكل List مباشرة
        if (data is List) {
          return data.map((e) => e.toString()).toList();
        }
        // لو الباك إند باعتها جوه object اسمه stations
        if (data['stations'] != null) {
          return (data['stations'] as List).map((e) => e.toString()).toList();
        }
      } else {
        print("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Network Error: $e");
    }
    
    // هيرجع لستة فاضية لو مفيش نت أو السيرفر واقع
    return [];
  }

  // 🚀 الدالة اللي بتربط زرار البحث بصفحة المقارنة
  static Future<Map<String, dynamic>> getCompareRoutes(String from, String to) async {
    try {
      final uri = Uri.parse('$baseUrl/compare').replace(queryParameters: {
        'start': from,
        'end': to,
        'gender': 'any',
      });
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {
      print("Failed to fetch compare routes");
    }
    return {};
  }

  Future<User?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode != 200) return null;
    final data = jsonDecode(response.body);
    token = data['token'];
    return User.fromJson(data['user'] ?? data);
  }

  Future<User?> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) return null;
    final data = jsonDecode(response.body);
    token = data['token'];
    return User.fromJson(data['user'] ?? data);
  }

  Future<List<app_route.Route>> getRoutes({String? from, String? to, String? transport}) async {
    final compareRoutes = await getCompareRoutesAsRoutes(from: from, to: to, transport: transport);
    final routes = <app_route.Route>[...compareRoutes];

    try {
      final uri = Uri.parse('$baseUrl/routes').replace(queryParameters: {
        if (from != null && from.isNotEmpty) 'from': from,
        if (to != null && to.isNotEmpty) 'to': to,
        if (from != null && from.isNotEmpty) 'start': from,
        if (to != null && to.isNotEmpty) 'end': to,
      });
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return routes;
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['routes'] ?? data['data'] ?? data['rides'] ?? []) as List;
      for (final json in list) {
        final route = app_route.Route.fromJson(json);
        if (!routes.any((item) => item.id == route.id)) routes.add(route);
      }
    } catch (_) {
      return routes;
    }
    return routes;
  }

  Future<List<app_route.Route>> getCompareRoutesAsRoutes({String? from, String? to, String? transport}) async {
    if (from == null || from.isEmpty || to == null || to.isEmpty) return [];

    try {
      final uri = Uri.parse('$baseUrl/compare').replace(queryParameters: {
        'start': from,
        'end': to,
        'gender': 'any',
      });
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['error'] != null) return [];

      final routes = <app_route.Route>[];
      final fastest = _routeFromCompareOption(data['fastest'], from, to, 'fastest', transport);
      final cheapest = _routeFromCompareOption(data['cheapest'], from, to, 'cheapest', transport);
      final sharedRide = _routeFromSharedRide(data['shared_ride'], from, to);

      if (fastest != null) routes.add(fastest);
      if (cheapest != null && cheapest.id != fastest?.id) routes.add(cheapest);
      if (sharedRide != null) routes.add(sharedRide);

      return routes;
    } catch (_) {
      return [];
    }
  }

  app_route.Route? _routeFromCompareOption(dynamic value, String from, String to, String tag, String? requestedTransport) {
    if (value is! Map<String, dynamic>) return null;
    final price = value['total_price_egp'] ?? value['price_egp'] ?? value['price'] ?? 0;
    final time = value['total_time_min'] ?? value['time_min'] ?? value['time'] ?? '';
    final steps = value['steps'] is List ? value['steps'] as List : const [];
    final firstType = steps.isNotEmpty && steps.first is Map ? (steps.first as Map)['type']?.toString() : null;

    return app_route.Route(
      id: value['id']?.toString() ?? '$tag-$from-$to-${price.toString()}-${time.toString()}',
      start: from,
      end: to,
      time: _formatMinutes(time),
      cost: _toDouble(price),
      transfers: steps.length > 1 ? steps.length - 1 : 0,
      transport_type: requestedTransport == 'bus' || requestedTransport == 'microbus' ? requestedTransport! : _normalizeTransportType(firstType ?? value['type']?.toString() ?? 'bus'),
      driver_name: tag == 'fastest' ? 'Fastest Route' : 'Cheapest Route',
      driver_rating: 4.8,
      car_model: 'Public transport option',
      available_seats: 20,
      total_seats: 20,
      female_only: false,
    );
  }

  app_route.Route? _routeFromSharedRide(dynamic value, String from, String to) {
    if (value is! Map<String, dynamic>) return null;
    final price = value['price_egp'] ?? value['total_price_egp'] ?? value['price'] ?? 0;
    final time = value['time_min'] ?? value['total_time_min'] ?? value['time'] ?? '';
    final gender = value['gender_preference']?.toString().toLowerCase();

    return app_route.Route(
      id: value['id']?.toString() ?? value['_id']?.toString() ?? 'shared-$from-$to-${value['driver_id'] ?? DateTime.now().millisecondsSinceEpoch}',
      start: value['start']?.toString() ?? value['from']?.toString() ?? from,
      end: value['end']?.toString() ?? value['to']?.toString() ?? to,
      time: _formatMinutes(time),
      cost: _toDouble(price),
      transfers: 0,
      transport_type: 'ride_share',
      driver_name: value['driver_name']?.toString() ?? value['driver_id']?.toString() ?? 'Driver',
      driver_rating: _toDouble(value['driver_rating'] ?? 4.8),
      car_model: value['car_model']?.toString() ?? value['car']?.toString() ?? 'Shared ride',
      available_seats: _toNullableInt(value['available_seats']) ?? 1,
      total_seats: _toNullableInt(value['total_seats']) ?? _toNullableInt(value['available_seats']) ?? 1,
      female_only: gender == 'female',
    );
  }

  String _normalizeTransportType(String value) {
    final type = value.toLowerCase().trim();
    if (type.contains('micro')) return 'microbus';
    if (type.contains('share') || type.contains('car')) return 'ride_share';
    return 'bus';
  }

  String _formatMinutes(dynamic value) {
    final minutesDouble = _toDouble(value);
    if (minutesDouble <= 0) return value?.toString() ?? '';
    final minutes = minutesDouble.round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<app_route.Route?> createRoute(app_route.Route route) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes'),
        headers: headers,
        body: jsonEncode(route.toCreateJson()),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final data = jsonDecode(response.body);
      return app_route.Route.fromJson(data['route'] ?? data['ride'] ?? data['data'] ?? data);
    } catch (_) {
      return null;
    }
  }

  Future<Booking?> createBooking(String userId, String routeId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/booking'),
        headers: headers,
        body: jsonEncode({'user_id': userId, 'route_id': routeId}),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 && response.statusCode != 201) return null;
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['booking'] ?? data);
    } catch (_) {
      return null;
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/booking/$userId'), headers: headers).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body);
      final list = data is List ? data : (data['bookings'] ?? data['data'] ?? []) as List;
      return list.map((json) => Booking.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }
}
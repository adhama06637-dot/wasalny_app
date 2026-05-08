import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final Map<String, dynamic> routeData;

  const MapScreen({super.key, required this.routeData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  bool isLoading = true;
  String? errorMessage;

  LatLng? startPoint;
  LatLng? endPoint;
  String startName = '';
  String endName = '';

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final path = widget.routeData['path'] as List<dynamic>?;

      if (path == null || path.length < 2) {
        setState(() {
          errorMessage = 'No route path found';
          isLoading = false;
        });
        return;
      }

      startName = path.first.toString();
      endName = path.last.toString();

      final start = await _getCoordinates(startName);
      final end = await _getCoordinates(endName);

      if (start == null || end == null) {
        setState(() {
          errorMessage = 'Could not find coordinates for stations';
          isLoading = false;
        });
        return;
      }

      startPoint = start;
      endPoint = end;

      final points = await _getRoutePoints(start, end);

      setState(() {
        routePoints = points;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading route: $e';
        isLoading = false;
      });
    }
  }

  // طريقة كلاود الممتازة في البحث عن المكان
  Future<LatLng?> _getCoordinates(String stationName) async {
    try {
      final query = Uri.encodeComponent('$stationName, Cairo, Egypt');
      final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'WasalnyApp/1.0'},
      );

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) return null;

      return LatLng(
        double.parse(data[0]['lat'].toString()),
        double.parse(data[0]['lon'].toString()),
      );
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  // الـ API بتاعنا (OSRM) المجاني اللي بيرسم الشوارع ومبيحتاجش Token يخلص
  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
      
      final response = await http.get(url);
      
      if (response.statusCode != 200) {
        return [start, end];
      }

      final data = jsonDecode(response.body);
      final geometry = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      return geometry.map<LatLng>((point) {
        final p = point as List<dynamic>;
        return LatLng(
          double.parse(p[1].toString()),
          double.parse(p[0].toString()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting route points: $e');
      return [start, end];
    }
  }

  LatLng _getCenter() {
    if (startPoint != null && endPoint != null) {
      return LatLng(
        (startPoint!.latitude + endPoint!.latitude) / 2,
        (startPoint!.longitude + endPoint!.longitude) / 2,
      );
    }
    return const LatLng(30.0444, 31.2357);
  }

  @override
  Widget build(BuildContext context) {
    final totalTime = widget.routeData['total_time_min']?.toString() ?? '--';
    final totalPrice = widget.routeData['total_price_egp']?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2D), // لون داكن يمشي مع خريطة أوبر
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$startName → $endName',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (!isLoading && errorMessage == null)
            FlutterMap(
              options: MapOptions(
                initialCenter: _getCenter(),
                initialZoom: 12,
              ),
              children: [
                // 🌟 خريطة أوبر (Dark Mode)
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  userAgentPackageName: 'com.wasalny.app',
                ),

                // 🌟 مسار الشارع (لون أخضر فاقع)
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFF00E676),
                      ),
                    ],
                  ),

                MarkerLayer(
                  markers: [
                    if (startPoint != null)
                      Marker(
                        point: startPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on, color: Colors.blue, size: 40),
                      ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red, size: 40),
                      ),
                  ],
                ),
              ],
            ),

          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF00E676)),
                  SizedBox(height: 16),
                  Text('Loading your route...', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),

          if (!isLoading && errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadRoute,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E2D)),
                  ),
                ],
              ),
            ),

          // 🌟 الكارت المدمج (UI كلاود + زرار Start Trip)
          if (!isLoading && errorMessage == null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Icon(Icons.access_time, color: Color(0xFF1E1E2D)),
                          const SizedBox(height: 4),
                          Text('$totalTime min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Duration', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ]),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        Column(children: [
                          const Icon(Icons.attach_money, color: Color(0xFF1E1E2D)),
                          const SizedBox(height: 4),
                          Text('$totalPrice EGP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Text('Price', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ]),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        GestureDetector(
                          onTap: _loadRoute,
                          child: const Column(children: [
                            Icon(Icons.refresh, color: Color(0xFF1E1E2D)),
                            SizedBox(height: 4),
                            Text('Reload', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // زرار Start Trip الجديد
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Starting Trip & Tracking... 🚀')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676), // أخضر فاقع
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: const Text('Start Trip', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
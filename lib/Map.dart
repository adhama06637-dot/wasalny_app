import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// ══════════════════════════════════════════════
// شاشة الخريطة — بتعرض المسار الحقيقي ديناميكياً
// بتاخد routeData من شاشة RouteDetailsScreen
// ══════════════════════════════════════════════
class MapScreen extends StatefulWidget {
  final Map<String, dynamic> routeData;

  const MapScreen({super.key, required this.routeData});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];
  bool  isLoading = true;
  String? errorMessage;

  // إحداثيات البداية والنهاية
  LatLng? startPoint;
  LatLng? endPoint;
  String  startName = '';
  String  endName   = '';

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  // ══════════════════════════════════════════════
  // الدالة الرئيسية — بتجيب الإحداثيات وترسم المسار
  // ══════════════════════════════════════════════
  Future<void> _loadRoute() async {
    setState(() {
      isLoading    = true;
      errorMessage = null;
    });

    try {
      // جيب الـ path من الـ routeData
      final path = widget.routeData['path'] as List<dynamic>?;

      if (path == null || path.length < 2) {
        setState(() {
          errorMessage = 'No route path found';
          isLoading    = false;
        });
        return;
      }

      // اخد أول وآخر محطة
      startName = path.first.toString();
      endName   = path.last.toString();

      // حول أسماء المحطات لإحداثيات
      final start = await _getCoordinates(startName);
      final end   = await _getCoordinates(endName);

      if (start == null || end == null) {
        setState(() {
          errorMessage = 'Could not find coordinates for stations';
          isLoading    = false;
        });
        return;
      }

      startPoint = start;
      endPoint   = end;

      // جيب نقاط المسار على الخريطة
      final points = await _getRoutePoints(start, end);

      setState(() {
        routePoints = points;
        isLoading   = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading route: $e';
        isLoading    = false;
      });
    }
  }

  // ══════════════════════════════════════════════
  // بتحول اسم المحطة لإحداثيات GPS
  // ══════════════════════════════════════════════
  Future<LatLng?> _getCoordinates(String stationName) async {
    try {
      // بنضيف Cairo عشان الـ search يبقى أدق
      final query  = Uri.encodeComponent('$stationName, Cairo, Egypt');
      final url    = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

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
      debugPrint('Error getting coordinates for $stationName: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════
  // بتجيب نقاط المسار على الطريق الفعلي
  // ══════════════════════════════════════════════
  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openrouteservice.org/v2/directions/driving-car'),
        headers: {
          'Authorization':
              'eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImVhMTE5Y2VlNzg0OTQxNDc5NDMzNmYzZmE0ODJmYzMzIiwiaCI6Im11cm11cjY0In0=',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'coordinates': [
            [start.longitude, start.latitude],
            [end.longitude,   end.latitude],
          ]
        }),
      );

      if (response.statusCode != 200) {
        // لو الـ API فشلت، ارسم خط مباشر بين النقطتين
        return [start, end];
      }

      final data   = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;

      return coords.map<LatLng>((point) {
        final p = point as List<dynamic>;
        return LatLng(
          double.parse(p[1].toString()),
          double.parse(p[0].toString()),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting route points: $e');
      // لو في error، ارسم خط مباشر
      return [start, end];
    }
  }

  // حساب مركز الخريطة بين البداية والنهاية
  LatLng _getCenter() {
    if (startPoint != null && endPoint != null) {
      return LatLng(
        (startPoint!.latitude  + endPoint!.latitude)  / 2,
        (startPoint!.longitude + endPoint!.longitude) / 2,
      );
    }
    // Cairo default
    return const LatLng(30.0444, 31.2357);
  }

  @override
  Widget build(BuildContext context) {
    final totalTime  = widget.routeData['total_time_min']?.toString()  ?? '--';
    final totalPrice = widget.routeData['total_price_egp']?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$startName → $endName',
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [

          // ── الخريطة ──
          if (!isLoading && errorMessage == null)
            FlutterMap(
              options: MapOptions(
                initialCenter: _getCenter(),
                initialZoom:   12,
              ),
              children: [
                // طبقة OpenStreetMap
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.wasalny.app',
                ),

                // خط المسار
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points:      routePoints,
                        strokeWidth: 5,
                        color:       const Color(0xFF303099),
                      ),
                    ],
                  ),

                // ماركر البداية والنهاية
                MarkerLayer(
                  markers: [
                    if (startPoint != null)
                      Marker(
                        point: startPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 40,
                        ),
                      ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),

          // ── Loading ──
          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF303099)),
                  SizedBox(height: 16),
                  Text('Loading your route...',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            ),

          // ── Error ──
          if (!isLoading && errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadRoute,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF303099)),
                    ),
                  ],
                ),
              ),
            ),

          // ── Info Card في الأسفل ──
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
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // الوقت
                    Column(children: [
                      const Icon(Icons.access_time,
                          color: Color(0xFF303099)),
                      const SizedBox(height: 4),
                      Text('$totalTime min',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Duration',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),

                    Container(width: 1, height: 40, color: Colors.grey.shade200),

                    // السعر
                    Column(children: [
                      const Icon(Icons.attach_money,
                          color: Color(0xFF303099)),
                      const SizedBox(height: 4),
                      Text('$totalPrice EGP',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const Text('Price',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),

                    Container(width: 1, height: 40, color: Colors.grey.shade200),

                    // زرار إعادة التحميل
                    GestureDetector(
                      onTap: _loadRoute,
                      child: Column(children: [
                        const Icon(Icons.refresh, color: Color(0xFF303099)),
                        const SizedBox(height: 4),
                        const Text('Reload',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text('Route',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ]),
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
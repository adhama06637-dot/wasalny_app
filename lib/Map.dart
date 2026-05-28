import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart'; 

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

  final MapController _mapController = MapController();
  final Location _location = Location();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;
  bool _isTracking = false;
  
  // متغيرات التتبع الذكي
  Timer? _trackingTimer;
  String _trackStatus = 'on_track';

  @override
  void initState() {
    super.initState();
    _loadRoute();
    _initLocation(); 
    _startLiveTracking(); // بدء التتبع عند فتح الشاشة
  }

  @override
  void dispose() {
    _locationSubscription?.cancel(); 
    _trackingTimer?.cancel(); // إيقاف التايمر عند إغلاق الشاشة لمنع استهلاك البطارية والنت
    super.dispose();
  }

  // دالة التتبع الحي وإعادة الحساب (Recalculation Logic)
  void _startLiveTracking() {
    _trackingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_currentLocation != null && _isTracking) {
        try {
          final path = widget.routeData['path'] as List<dynamic>? ?? [];
          
          final response = await http.post(
            Uri.parse('https://wasalny-phi.vercel.app/track'), // ⚠️ ضع رابط سيرفرك هنا
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'current_location': '${_currentLocation!.latitude},${_currentLocation!.longitude}',
              'destination': endName,
              'current_path': path,
            }),
          );
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            setState(() {
              _trackStatus = data['status'];
            });

            if (data['status'] == 'off_route') {
              print("Warning: Off Route! Recalculating path...");
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Off route! Recalculating... 🔄'), duration: Duration(seconds: 2)),
              );
              _loadRoute(); // إعادة تحميل المسار بناءً على الموقع الجديد
            }
          }
        } catch (e) {
          debugPrint('Tracking API error: $e');
        }
      }
    });
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _currentLocation = await _location.getLocation();
    if (mounted) setState(() {});
  }

  void _startTrip() {
    setState(() { _isTracking = true; });

    if (_currentLocation != null) {
      _mapController.move(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), 17.0);
    }

    _locationSubscription = _location.onLocationChanged.listen((LocationData loc) {
      if (mounted) {
        setState(() { _currentLocation = loc; });
        if (_isTracking) {
          _mapController.move(LatLng(loc.latitude!, loc.longitude!), 17.0);
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip Started! GPS tracking activated 🚀'), backgroundColor: Color(0xFF00E676)),
    );
  }

  Future<void> _loadRoute() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final path = widget.routeData['path'] as List<dynamic>?;
      if (path == null || path.length < 2) {
        setState(() { errorMessage = 'No route path found'; isLoading = false; });
        return;
      }

      startName = path.first.toString();
      endName = path.last.toString();

      final start = await _getCoordinates(startName);
      final end = await _getCoordinates(endName);

      if (start == null || end == null) {
        setState(() { errorMessage = 'Could not find coordinates for stations'; isLoading = false; });
        return;
      }

      startPoint = start;
      endPoint = end;

      final points = await _getRoutePoints(start, end);
      setState(() { routePoints = points; isLoading = false; });
    } catch (e) {
      setState(() { errorMessage = 'Error loading route: $e'; isLoading = false; });
    }
  }

  Future<LatLng?> _getCoordinates(String stationName) async {
    try {
      final query = Uri.encodeComponent('$stationName, Cairo, Egypt');
      final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';
      final response = await http.get(Uri.parse(url), headers: {'User-Agent': 'WasalnyApp/1.0'});
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) return null;
      return LatLng(double.parse(data[0]['lat'].toString()), double.parse(data[0]['lon'].toString()));
    } catch (e) {
      return null;
    }
  }

  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse('http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');
      final response = await http.get(url);
      if (response.statusCode != 200) return [start, end];
      final data = jsonDecode(response.body);
      final geometry = data['routes'][0]['geometry']['coordinates'] as List<dynamic>;
      return geometry.map<LatLng>((point) {
        final p = point as List<dynamic>;
        return LatLng(double.parse(p[1].toString()), double.parse(p[0].toString()));
      }).toList();
    } catch (e) {
      return [start, end];
    }
  }

  LatLng _getCenter() {
    if (startPoint != null && endPoint != null) {
      return LatLng((startPoint!.latitude + endPoint!.latitude) / 2, (startPoint!.longitude + endPoint!.longitude) / 2);
    }
    return const LatLng(30.0444, 31.2357);
  }

  @override
  Widget build(BuildContext context) {
    final totalTime = widget.routeData['total_time_min']?.toString() ?? '--';
    final totalPrice = widget.routeData['total_price_egp']?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2D), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('$startName → $endName', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (!isLoading && errorMessage == null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _getCenter(),
                initialZoom: 12,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && _isTracking) setState(() => _isTracking = false);
                },
              ),
              children: [
                TileLayer(urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png', subdomains: const ['a', 'b', 'c', 'd'], userAgentPackageName: 'com.wasalny.app'),
                if (routePoints.isNotEmpty)
                  PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 5, color: const Color(0xFF00E676))]),
                MarkerLayer(
                  markers: [
                    if (startPoint != null) Marker(point: startPoint!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.blue, size: 40)),
                    if (endPoint != null) Marker(point: endPoint!, width: 40, height: 40, child: const Icon(Icons.flag, color: Colors.red, size: 40)),
                    if (_currentLocation != null)
                      Marker(
                        point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                        width: 24, height: 24,
                        child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10, spreadRadius: 5)])),
                      ),
                  ],
                ),
              ],
            ),
          if (isLoading) const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
          
          // ويدجت الحالة (اختياري لمتابعة الـ Recalculation)
          if (_isTracking)
            Positioned(
              top: 10, left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text('Status: $_trackStatus', style: const TextStyle(color: Colors.white)),
              ),
            ),

          if (_currentLocation != null && !_isTracking && !isLoading && errorMessage == null)
            Positioned(
              right: 16, bottom: 180,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  setState(() { _isTracking = true; });
                  _mapController.move(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), 17.0);
                },
                child: const Icon(Icons.my_location, color: Color(0xFF1E1E2D)),
              ),
            ),
          if (!isLoading && errorMessage == null)
            Positioned(
              bottom: 16, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [const Icon(Icons.access_time, color: Color(0xFF1E1E2D)), Text('$totalTime min', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                        Container(width: 1, height: 40, color: Colors.grey.shade300),
                        Column(children: [const Icon(Icons.attach_money, color: Color(0xFF1E1E2D)), Text('$totalPrice EGP', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: ElevatedButton(
                        onPressed: _isTracking ? null : _startTrip,
                        style: ElevatedButton.styleFrom(backgroundColor: _isTracking ? Colors.grey : const Color(0xFF00E676), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        child: Text(_isTracking ? 'Tracking Active 📍' : 'Start Trip', style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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
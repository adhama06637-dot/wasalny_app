import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routePoints = [];

  Future<LatLng> getCoordinates(String place) async {
    final response = await http.get(
      Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$place&format=json"),
      headers: {"User-Agent": "flutter_app"},
    );

    final data = jsonDecode(response.body);

    return LatLng(
      double.parse(data[0]['lat']),
      double.parse(data[0]['lon']),
    );
  }

  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final response = await http.post(
      Uri.parse("https://api.heigit.org/v2/directions/driving-car"),
      headers: {
        "Authorization": "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6ImVhMTE5Y2VlNzg0OTQxNDc5NDMzNmYzZmE0ODJmYzMzIiwiaCI6Im11cm11cjY0In0=",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "coordinates": [
          [start.longitude, start.latitude],
          [end.longitude, end.latitude],
        ]
      }),
    );

    final data = jsonDecode(response.body);
    final coords = data['routes'][0]['geometry']['coordinates'];

    return coords.map<LatLng>((point) {
      return LatLng(point[1], point[0]);
    }).toList();
  }

  void getRouteNow() async {
    final from = await getCoordinates("Cairo");
    final to = await getCoordinates("Giza");

    final route = await getRoute(from, to);

    setState(() {
      routePoints = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: getRouteNow,
            child: Text("Show Route"),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(30.0444, 31.2357),
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.waslny.app",
                  ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/station.dart';

class MapWidget extends StatefulWidget {
  final List<Station>? stations;
  final Function(LatLng)? onTap;
  final LatLng? initialPosition;
  final Set<Marker>? markers;

  const MapWidget({
    super.key,
    this.stations,
    this.onTap,
    this.initialPosition,
    this.markers,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(30.0444, 31.2357); // القاهرة
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _isLoading = false;
          });
        }
      } else {
        // الإذن مرفوض - استخدم موقع افتراضي (القاهرة)
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      // خطأ في الحصول على الموقع - استخدم موقع افتراضي
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

    _addStationsMarkers();
  }

  void _addStationsMarkers() {
    final markers = <Marker>{};

    // إضافة محطات الميكروباص والباص
    if (widget.stations != null) {
      for (var station in widget.stations!) {
        markers.add(
          Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            infoWindow: InfoWindow(
              title: station.name,
              snippet: '${station.type} - ${station.lines.join(", ")}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              station.type == 'microbus'
                  ? BitmapDescriptor.hueOrange
                  : station.type == 'bus'
                  ? BitmapDescriptor.hueBlue
                  : BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
    }

    // إضافة markers من الخارج
    if (widget.markers != null) {
      markers.addAll(widget.markers!);
    }

    if (mounted) {
      setState(() => _markers = markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF3F3D9F)),
              SizedBox(height: 16),
              Text('جاري تحديد الموقع...'),
            ],
          ),
        ),
      );
    }

    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition ?? _currentPosition,
        zoom: 13,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: true,
      markers: _markers,
      onMapCreated: (controller) => _mapController = controller,
      onTap: widget.onTap,
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void animateTo(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }
}
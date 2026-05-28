import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/route.dart' as app_route;
import '../providers/app_provider.dart';
import 'app_colors.dart';
import 'captain_requests_screen.dart';

class PublishTripScreen extends StatefulWidget {
  const PublishTripScreen({super.key});

  @override
  State<PublishTripScreen> createState() => _PublishTripScreenState();
}

class _PublishTripScreenState extends State<PublishTripScreen> {
  static const areas = ['October', '6 October', 'Maadi', 'Nasr City', 'Sheikh Zayed', 'Dokki', 'Mohandessin', 'Heliopolis', 'New Cairo', 'Zamalek', 'Downtown', 'Giza'];

  int seats = 3;
  int minimumRiders = 1;
  double cost = 40;
  bool female = false;

  final start = TextEditingController(text: '6 October');
  final end = TextEditingController(text: 'Maadi');
  final time = TextEditingController(text: '5:00 PM');
  final carModel = TextEditingController(text: 'Hyundai Elantra');
  final carColor = TextEditingController(text: 'Silver');
  final plateNumber = TextEditingController();

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    time.dispose();
    carModel.dispose();
    carColor.dispose();
    plateNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Create Private Car Ride', style: TextStyle(fontWeight: FontWeight.w900)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(20)),
            child: const Row(children: [
              CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.directions_car_filled_rounded, color: AppColors.primary)),
              SizedBox(width: 12),
              Expanded(child: Text('Register your private car trip and share seats with people going the same way.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 16),
          _sectionTitle('Trip Details'),
          _locationField('From', start),
          const SizedBox(height: 12),
          _locationField('To', end),
          const SizedBox(height: 12),
          _field('Departure Time', time, Icons.access_time_rounded),
          const SizedBox(height: 16),
          _sectionTitle('Private Car Details'),
          _field('Car Model', carModel, Icons.directions_car_filled_rounded),
          const SizedBox(height: 12),
          _field('Car Color', carColor, Icons.palette_outlined),
          const SizedBox(height: 12),
          _field('Plate Number (optional)', plateNumber, Icons.confirmation_number_outlined),
          const SizedBox(height: 16),
          _step('Available Seats', seats, (v) => setState(() => seats = v.clamp(1, 6))),
          const SizedBox(height: 12),
          _step('Minimum Riders', minimumRiders, (v) => setState(() => minimumRiders = v.clamp(1, seats))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(radius: 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Price per Seat: ${cost.round()} EGP', style: const TextStyle(fontWeight: FontWeight.w900)),
              Slider(value: cost, min: 20, max: 150, divisions: 26, label: '${cost.round()} EGP', onChanged: (v) => setState(() => cost = v)),
            ]),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: female,
            onChanged: (v) => setState(() => female = v),
            title: const Text('Female Only Ride', style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Only female passengers can join this private car trip'),
            secondary: const Icon(Icons.female_rounded, color: Colors.pink),
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              onPressed: provider.isLoading ? null : _publishRide,
              icon: provider.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.publish_rounded),
              label: Text(provider.isLoading ? 'Publishing...' : 'Publish Private Ride', style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _publishRide() async {
    final provider = context.read<AppProvider>();
    final car = '${carModel.text.trim()} - ${carColor.text.trim()}${plateNumber.text.trim().isEmpty ? '' : ' • ${plateNumber.text.trim()}'}';
    final ok = await provider.publishRoute(
      app_route.Route(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        start: start.text.trim(),
        end: end.text.trim(),
        time: time.text.trim(),
        cost: cost,
        transfers: 0,
        transport_type: 'ride_share',
        driver_name: provider.currentUser?.name ?? 'Private Car Driver',
        car_model: car,
        available_seats: seats,
        total_seats: seats,
        female_only: female,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Private ride published successfully' : 'Could not publish private ride')));
    if (ok) {
      final route = provider.lastPublishedRoute;
      if (route == null) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CaptainRequestsScreen(route: route)));
      }
    }
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      );

  Widget _locationField(String label, TextEditingController controller) => Autocomplete<String>(
        initialValue: TextEditingValue(text: controller.text),
        optionsBuilder: (value) {
          final text = value.text.trim().toLowerCase();
          if (text.isEmpty) return areas;
          return areas.where((area) => area.toLowerCase().contains(text));
        },
        onSelected: (value) => controller.text = value,
        fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
          if (textController.text != controller.text) textController.text = controller.text;
          textController.addListener(() => controller.text = textController.text);
          return TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          );
        },
      );

  Widget _field(String label, TextEditingController controller, IconData icon) => TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );

  Widget _step(String label, int value, ValueChanged<int> onChanged) => Container(
        padding: const EdgeInsets.all(14),
        decoration: cardDecoration(radius: 12),
        child: Row(children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const Spacer(),
          IconButton(onPressed: () => onChanged(value - 1), icon: const Icon(Icons.remove_circle_outline_rounded)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w900)),
          IconButton(onPressed: () => onChanged(value + 1), icon: const Icon(Icons.add_circle_outline_rounded)),
        ]),
      );
}

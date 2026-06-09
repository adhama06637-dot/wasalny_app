import 'package:flutter/material.dart';
import 'app_colors.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Women's Safety")),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Container(height: 180, decoration: BoxDecoration(color: AppColors.secondary.withOpacity(.12), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.woman, color: AppColors.secondary, size: 100)),
        const SizedBox(height: 22),
        const Text('We care about your safety', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const Text('All female-only rides are verified. Your safety is our priority.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18),
        _item(Icons.female, 'Female Only Rides', 'Ride with female drivers & passengers'),
        _item(Icons.verified_user, 'Verified Drivers', 'All drivers are verified'),
        _item(Icons.emergency, 'Emergency Assistance', 'Share live location & get help'),
        const SizedBox(height: 20),
        SizedBox(height: 54, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white), onPressed: () {}, icon: const Icon(Icons.phone), label: const Text('Emergency'))),
      ]),
    );
  }
  Widget _item(IconData icon, String title, String subtitle) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(14), decoration: cardDecoration(), child: Row(children: [Icon(icon, color: AppColors.primary), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(subtitle, style: const TextStyle(color: AppColors.muted, fontSize: 12))]))]));
}
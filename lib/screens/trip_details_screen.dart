import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route.dart' as app_route;
import '../providers/app_provider.dart';
import 'app_colors.dart';
import 'payment_screen.dart';

class TripDetailsScreen extends StatelessWidget {
  const TripDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final route = context.watch<AppProvider>().selectedRoute;
    if (route == null) return const Scaffold(body: Center(child: Text('No route selected')));
    final steps = _steps(route);
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7FF),
      appBar: AppBar(backgroundColor: Colors.white, leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)), title: const Text('Route Details', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 90), children: [
        Container(padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12), decoration: BoxDecoration(color: const Color(0xFFF7F5FF), borderRadius: BorderRadius.circular(22)), child: Row(children: [Expanded(child: _summary(Icons.access_time, Colors.blue, 'Estimated Time', route.time)), Container(width: 1, height: 54, color: Colors.grey.shade300), Expanded(child: _summary(Icons.account_balance_wallet, AppColors.secondary, 'Estimated Cost', '${route.cost.toStringAsFixed(0)} EGP'))])),
        const SizedBox(height: 34),
        const Text('Your Route', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 22),
        ...List.generate(steps.length, (index) => _StepTile(index: index, step: steps[index], isLast: index == steps.length - 1)),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(20), decoration: cardDecoration(radius: 18), child: const Row(children: [CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.flag, color: Colors.white)), SizedBox(width: 18), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('You arrived', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 6), Text('successfully!', style: TextStyle(fontSize: 17, color: Colors.green, fontWeight: FontWeight.w900))])), Text('🎉', style: TextStyle(fontSize: 30))])),
        const SizedBox(height: 22),
        SizedBox(height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(route: route))), child: const Text('Book & Pay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)))),
      ]),
    );
  }

  Widget _summary(IconData icon, Color color, String title, String value) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircleAvatar(radius: 26, backgroundColor: color, child: Icon(icon, color: Colors.white)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontSize: 15)), const SizedBox(height: 6), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900))])]);

  List<_RouteStepData> _steps(app_route.Route route) {
    if (route.transport_type == 'bus') return [_RouteStepData('Ride bus', 'from ${route.start}', 'to Ramses', '25 min', '${(route.cost * .5).round()} EGP', Icons.directions_bus, Colors.blue), _RouteStepData('Then ride bus', 'from Ramses', 'to ${route.end}', '30 min', '${(route.cost * .5).round()} EGP', Icons.directions_bus, AppColors.secondary)];
    if (route.transport_type == 'ride_share') return [_RouteStepData('Ride share with ${route.driver_name ?? 'driver'}', 'from ${route.start}', 'to ${route.end}', route.time, '${route.cost.round()} EGP', Icons.directions_car, AppColors.secondary)];
    return [_RouteStepData('Ride microbus', 'from Hyper One Station', 'to Ramses', '15 min', '8 EGP', Icons.directions_bus, Colors.blue), _RouteStepData('Then ride microbus', 'from Ramses', 'to ${route.end}', '25 min', '12 EGP', Icons.directions_bus, AppColors.secondary)];
  }
}

class _RouteStepData { final String title, from, to, time, cost; final IconData icon; final Color color; const _RouteStepData(this.title, this.from, this.to, this.time, this.cost, this.icon, this.color); }

class _StepTile extends StatelessWidget {
  final int index; final _RouteStepData step; final bool isLast; const _StepTile({required this.index, required this.step, required this.isLast});
  @override Widget build(BuildContext context) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 66, child: Column(children: [CircleAvatar(radius: 28, backgroundColor: step.color, child: Stack(clipBehavior: Clip.none, children: [Icon(step.icon, color: Colors.white), Positioned(left: -18, top: -12, child: CircleAvatar(radius: 12, backgroundColor: step.color, child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))))])), if (!isLast) Container(width: 2, height: 112, color: Colors.grey.shade300)])),
    Expanded(child: Container(margin: const EdgeInsets.only(bottom: 28), padding: const EdgeInsets.all(22), decoration: cardDecoration(radius: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(step.title, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 18), Text(step.from, style: const TextStyle(color: Color(0xFF2D9CDB), fontSize: 17)), const SizedBox(height: 8), Text(step.to, style: const TextStyle(color: AppColors.secondary, fontSize: 17)), const SizedBox(height: 20), Row(children: [const Icon(Icons.access_time, size: 20), const SizedBox(width: 8), Text(step.time, style: const TextStyle(fontSize: 16)), const SizedBox(width: 28), const Icon(Icons.account_balance_wallet, size: 20), const SizedBox(width: 8), Text(step.cost, style: const TextStyle(fontSize: 16))])]))),
  ]);
}
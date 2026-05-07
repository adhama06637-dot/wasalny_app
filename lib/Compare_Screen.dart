import 'package:flutter/material.dart';
import 'map.dart';

// ══════════════════════════════════════════════
// شاشة المقارنة
// ══════════════════════════════════════════════
class CompareScreen extends StatefulWidget {
  final Map<String, dynamic> compareData;

  const CompareScreen({super.key, required this.compareData});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final fastest    = widget.compareData['fastest']     as Map<String, dynamic>?;
    final cheapest   = widget.compareData['cheapest']    as Map<String, dynamic>?;
    final sharedRide = widget.compareData['shared_ride'] as Map<String, dynamic>?;
    final tip        = widget.compareData['tip']?.toString() ?? '';
    final samePath   = widget.compareData['same_path']   as bool? ?? false;

    int optionsCount = 0;
    if (fastest != null) optionsCount++;
    if (!samePath && cheapest != null) optionsCount++;
    if (sharedRide != null) optionsCount++;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Route Options',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Toggle Compare/Details
            Container(
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text('Compare',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                        child: Text('Details',
                            style: TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tip Banner
            if (tip.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE8FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF303099)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF303099)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(tip,
                            style: const TextStyle(
                                color: Color(0xFF303099),
                                fontWeight: FontWeight.w500))),
                  ],
                ),
              ),

            Text('We found $optionsCount option${optionsCount != 1 ? 's' : ''} for you',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // كارت الأسرع
            if (fastest != null) ...[
              RouteOptionCard(
                badgeText: 'Fastest',
                badgeColor: Colors.green,
                icon: Icons.directions_subway,
                iconColor: Colors.blue,
                time: '${fastest['total_time_min']} min',
                price: '${fastest['total_price_egp']} EGP',
                leaveTime: 'Fastest Route ⚡',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeData: fastest))),
              ),
              const SizedBox(height: 12),
            ],

            // كارت الأرخص (بس لو المسارين مختلفين)
            if (!samePath && cheapest != null) ...[
              RouteOptionCard(
                badgeText: 'Cheapest',
                badgeColor: Colors.orange,
                icon: Icons.directions_bus,
                iconColor: const Color(0xFF6C63FF),
                time: '${cheapest['total_time_min']} min',
                price: '${cheapest['total_price_egp']} EGP',
                leaveTime: 'Cheapest Route 💰',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeData: cheapest))),
              ),
              const SizedBox(height: 12),
            ],

            // كارت الرايد شيرينج
            if (sharedRide != null) ...[
              SharedRideCard(ride: sharedRide),
              const SizedBox(height: 12),
            ],

            // لو مفيش رايد شيرينج
            if (sharedRide == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.directions_car_outlined, color: Colors.grey, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('No shared rides available',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                          Text('Check back later',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Ride'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// كارت المسار العادي
// ══════════════════════════════════════════════
class RouteOptionCard extends StatelessWidget {
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final Color iconColor;
  final String time;
  final String price;
  final String leaveTime;
  final VoidCallback onTap;

  const RouteOptionCard({
    super.key,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.iconColor,
    required this.time,
    required this.price,
    required this.leaveTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.emoji_events, color: badgeColor, size: 16),
                    const SizedBox(width: 4),
                    Text(badgeText,
                        style: TextStyle(
                            color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 6),
                  Text(time,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(leaveTime, style: TextStyle(color: badgeColor, fontSize: 12)),
                ],
              ),
            ),
            Text(price,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// كارت الرايد شيرينج
// ══════════════════════════════════════════════
class SharedRideCard extends StatelessWidget {
  final Map<String, dynamic> ride;

  const SharedRideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final price        = ride['price_egp']?.toString()         ?? '--';
    final seats        = ride['available_seats']?.toString()   ?? '--';
    final driverName   = ride['driver_name']?.toString()       ?? 'Unknown';
    final genderPref   = ride['gender_preference']?.toString() ?? 'any';
    final ridesCount   = ride['all_rides_count'] as int?        ?? 1;
    final pickupPoints = ride['pickup_points']   as List<dynamic>? ?? [];

    Color  genderColor = Colors.blue;
    String genderLabel = 'Any Gender';
    if (genderPref == 'female') { genderColor = Colors.pink;  genderLabel = 'Female Only 👩'; }
    else if (genderPref == 'male') { genderColor = Colors.blue; genderLabel = 'Male Only 👨'; }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
              child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: const [
                  Icon(Icons.star, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text('Comfortable 🚗',
                      style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 4),
                const Text('Shared Ride',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Driver: $driverName',
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ]),
            ),
            Text('$price EGP',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(children: [
            _Chip(icon: Icons.event_seat, label: '$seats seats', color: Colors.green),
            const SizedBox(width: 8),
            _Chip(icon: Icons.person, label: genderLabel, color: genderColor),
          ]),
          if (pickupPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Pickup: ${pickupPoints.join(', ')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
          if (ridesCount > 1) ...[
            const SizedBox(height: 6),
            Text('$ridesCount rides available →',
                style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Booking ride with $driverName...'),
                  backgroundColor: const Color(0xFF6C63FF),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Book This Ride',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Chip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
// شاشة تفاصيل المسار + زرار Start Trip
// ══════════════════════════════════════════════
class RouteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RouteDetailsScreen({super.key, required this.routeData});

  Map<String, dynamic> _getTransportStyle(String type) {
    switch (type.toLowerCase()) {
      case 'metro':
        return {'icon': Icons.directions_subway, 'color': const Color(0xFF1565C0)};
      case 'bus':
        return {'icon': Icons.directions_bus, 'color': const Color(0xFF2E7D32)};
      case 'microbus':
        return {'icon': Icons.airport_shuttle, 'color': const Color(0xFFE65100)};
      default:
        return {'icon': Icons.directions, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps      = routeData['steps']              as List<dynamic>? ?? [];
    final totalTime  = routeData['total_time_min']?.toString()   ?? '--';
    final totalPrice = routeData['total_price_egp']?.toString()  ?? '--';
    final totalDist  = routeData['total_distance_km']?.toString() ?? '--';
    final isRushHour = routeData['is_rush_hour']       as bool?    ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Route Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),

      // ── زرار Start Trip ──
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => MapScreen(routeData: routeData)),
            ),
            icon: const Icon(Icons.navigation, color: Colors.white),
            label: const Text('Start Trip',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF303099),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFEAE8FF),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(icon: Icons.access_time, label: 'Time', value: '$totalTime min'),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _SummaryItem(icon: Icons.attach_money, label: 'Price', value: '$totalPrice EGP'),
                  Container(width: 1, height: 40, color: Colors.grey.shade300),
                  _SummaryItem(icon: Icons.straighten, label: 'Distance', value: '$totalDist km'),
                ],
              ),
            ),

            if (isRushHour) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200)),
                child: Row(children: const [
                  Icon(Icons.warning_amber, color: Colors.red),
                  SizedBox(width: 8),
                  Text('🚨 Rush Hour — Expect delays',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                ]),
              ),
            ],

            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Step by step guide:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),

            // Steps
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step  = steps[index] as Map<String, dynamic>;
                final type  = step['type']?.toString() ?? '';
                final style = _getTransportStyle(type);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: (style['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle),
                      child: Icon(style['icon'] as IconData,
                          color: style['color'] as Color, size: 20),
                    ),
                    title: Text('From ${step['from']} to ${step['to']}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('$type • ${step['time_min']} min'),
                    trailing: Text('${step['price_egp']} EGP',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Color(0xFF303099))),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, color: const Color(0xFF303099), size: 22),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    ]);
  }
}
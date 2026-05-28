import 'package:flutter/material.dart';
import 'Map.dart'; 

// ══════════════════════════════════════════════
// شاشة المقارنة الرئيسية
// ══════════════════════════════════════════════
class CompareScreen extends StatefulWidget {
  final Map<String, dynamic> compareData;

  const CompareScreen({super.key, required this.compareData});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  int _selectedIndex = 0;

  // 🛠️ دالة تظبيط الوقت (ساعات ودقايق) مع حماية ضد الكسور
  String _formatDuration(dynamic minutesData) {
    if (minutesData == null || minutesData.toString().isEmpty) return '--';
    double? parsedValue = double.tryParse(minutesData.toString());
    if (parsedValue == null) return '--';
    int minutes = parsedValue.round();
    
    if (minutes <= 0) return '1 min';
    if (minutes < 60) return '$minutes min';
    
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    String hoursText = hours == 1 ? 'hr' : 'hrs';
    return remainingMinutes == 0 ? '$hours $hoursText' : '$hours $hoursText $remainingMinutes min';
  }

  String _formatPath(List<dynamic>? path) {
    if (path == null || path.isEmpty) return 'No path';
    return path.join(' → ');
  }

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
                badgeText: 'Fastest ⚡',
                badgeColor: Colors.green,
                icon: Icons.bolt,
                iconColor: const Color(0xFF1565C0),
                time: _formatDuration(fastest['total_time_min']),
                price: '${fastest['total_price_egp']} EGP',
                path: _formatPath(fastest['path'] as List<dynamic>?),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeData: fastest))),
              ),
              const SizedBox(height: 12),
            ],

            // كارت الأرخص
            if (!samePath && cheapest != null) ...[
              RouteOptionCard(
                badgeText: 'Cheapest 💰',
                badgeColor: Colors.orange,
                icon: Icons.directions_bus,
                iconColor: const Color(0xFF6C63FF),
                time: _formatDuration(cheapest['total_time_min']),
                price: '${cheapest['total_price_egp']} EGP',
                path: _formatPath(cheapest['path'] as List<dynamic>?),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => RouteDetailsScreen(routeData: cheapest))),
              ),
              const SizedBox(height: 12),
            ],

            if (sharedRide != null) ...[
              SharedRideCard(ride: sharedRide),
              const SizedBox(height: 12),
            ],

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
// كارت خيار المسار 
// ══════════════════════════════════════════════
class RouteOptionCard extends StatelessWidget {
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final Color iconColor;
  final String time;
  final String price;
  final String path;
  final VoidCallback onTap;

  const RouteOptionCard({
    super.key,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.iconColor,
    required this.time,
    required this.price,
    required this.path,
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
                        style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 6),
                  Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(path, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
    final price          = ride['price_egp']?.toString() ?? '--';
    final seats          = ride['available_seats']?.toString() ?? '--';
    final driverName     = ride['driver_id']?.toString() ?? 'Driver';
    final genderPref     = ride['gender_preference']?.toString() ?? 'any';
    
    // تظبيط وقت الرايد شيرينج كمان
    double? parsedValue = double.tryParse(ride['time_min']?.toString() ?? '');
    String timeStr = '--';
    if (parsedValue != null) {
      int minutes = parsedValue.round();
      if (minutes < 60) {
        timeStr = '$minutes min';
      } else {
        int h = minutes ~/ 60;
        int m = minutes % 60;
        timeStr = m == 0 ? '$h hr' : '$h hr $m min';
      }
    }

    Color genderColor = Colors.blue;
    String genderLabel = 'Any Gender';
    if (genderPref == 'female') {
      genderColor = Colors.pink;
      genderLabel = 'Female Only 👩';
    } else if (genderPref == 'male') {
      genderColor = Colors.blue;
      genderLabel = 'Male Only 👨';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFF6C63FF).withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                child: const Icon(Icons.directions_car, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 14),
                        SizedBox(width: 4),
                        Text('Comfortable 🚗', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$timeStr Shared Ride', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('Driver: $driverName', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text('$price EGP', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(icon: Icons.event_seat, label: '$seats seats left', color: Colors.green),
              const SizedBox(width: 8),
              _Chip(icon: Icons.person, label: genderLabel, color: genderColor),
            ],
          ),
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
              child: const Text('Book This Ride', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════
// شاشة تفاصيل المسار 
// ══════════════════════════════════════════════
class RouteDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RouteDetailsScreen({super.key, required this.routeData});

  // نفس دالة الوقت هنا كمان
  String _formatDuration(dynamic minutesData) {
    if (minutesData == null || minutesData.toString().isEmpty) return '--';
    double? parsedValue = double.tryParse(minutesData.toString());
    if (parsedValue == null) return '--';
    int minutes = parsedValue.round();
    
    if (minutes <= 0) return '1 min';
    if (minutes < 60) return '$minutes min';
    
    int hours = minutes ~/ 60;
    int remainingMinutes = minutes % 60;
    String hoursText = hours == 1 ? 'hr' : 'hrs';
    return remainingMinutes == 0 ? '$hours $hoursText' : '$hours $hoursText $remainingMinutes min';
  }

  Map<String, dynamic> _getTransportStyle(String type) {
    switch (type.toLowerCase()) {
      case 'bus':
        return {'icon': Icons.directions_bus, 'color': const Color(0xFF2E7D32)};
      case 'microbus':
        return {'icon': Icons.airport_shuttle, 'color': const Color(0xFFE65100)};
      default:
        return {'icon': Icons.directions_car, 'color': const Color(0xFF1565C0)};
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps      = routeData['steps']              as List<dynamic>? ?? [];
    final totalTime  = _formatDuration(routeData['total_time_min']); 
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
            icon: const Icon(Icons.map, color: Colors.white),
            label: const Text('Select & Show on Map',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
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
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFFEAE8FF),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(icon: Icons.access_time, label: 'Time', value: totalTime),
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

            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Your Route',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length + 1,
              itemBuilder: (context, index) {
                if (index == steps.length) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.flag, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Text('You arrived successfully! 🎉',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                final step    = steps[index] as Map<String, dynamic>;
                final from    = step['from']?.toString() ?? '';
                final to      = step['to']?.toString() ?? '';
                final type    = step['type']?.toString() ?? '';
                final timeMin = _formatDuration(step['time_min']); // تطبيق دالة الوقت هنا كمان
                final price   = step['price_egp']?.toString() ?? '--';
                final style   = _getTransportStyle(type);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: style['color'] as Color, shape: BoxShape.circle),
                          child: Center(child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ),
                        if (index < steps.length - 1)
                          Container(width: 2, height: 30, color: Colors.grey.shade300),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(style['icon'] as IconData, color: style['color'] as Color, size: 18),
                                const SizedBox(width: 6),
                                Text('Ride $type', style: TextStyle(color: style['color'] as Color, fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('from $from', style: const TextStyle(color: Color(0xFF303099), fontSize: 13)),
                            Text('to $to', style: const TextStyle(color: Color(0xFF303099), fontSize: 13)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(timeMin, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                const SizedBox(width: 16),
                                const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('$price EGP', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      Icon(icon, color: const Color(0xFF303099), size: 24),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]);
  }
}
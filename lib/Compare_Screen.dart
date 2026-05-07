import 'package:flutter/material.dart';

class CompareScreen extends StatefulWidget {
  final Map<String, dynamic> compareData;

  const CompareScreen({super.key, required this.compareData});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // دالة للانتقال لصفحة الحجز الوهمية بتاعت فايربيز
  void _navigateToNextPage(BuildContext context, String optionName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextPage(optionName: optionName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fastest = widget.compareData['fastest'] as Map<String, dynamic>?;
    final cheapest = widget.compareData['cheapest'] as Map<String, dynamic>?;
    final sharedRide = widget.compareData['shared_ride'] as Map<String, dynamic>?;
    final tip = widget.compareData['tip']?.toString() ?? '';

    // حساب عدد الطرق المتاحة
    int optionsCount = 0;
    if (fastest != null) optionsCount++;
    if (cheapest != null) optionsCount++;
    if (sharedRide != null) optionsCount++;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Route Options',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compare and Details Toggle 
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Compare',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Details',
                        style: TextStyle(
                            color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tip Banner من السيرفر
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
                      child: Text(
                        tip,
                        style: const TextStyle(
                          color: Color(0xFF303099),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              'We found $optionsCount options for you',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // 🌟 كارت 1: الأسرع 🌟
            if (fastest != null)
              RouteOptionCard(
                title: 'Microbus',
                time: '${fastest['total_time_min']} min',
                arrivalTime: '--', 
                price: '${fastest['total_price_egp']} EGP',
                leaveTime: 'Fastest Route ⚡',
                badgeText: 'Fastest',
                badgeColor: Colors.green,
                icon: Icons.directions_bus_filled, 
                iconColor: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailsScreen(routeData: fastest),
                    ),
                  );
                },
              ),
            if (fastest != null) const SizedBox(height: 12),

            // 🌟 كارت 2: الأرخص 🌟
            if (cheapest != null)
              RouteOptionCard(
                title: 'Bus',
                time: '${cheapest['total_time_min']} min',
                arrivalTime: '--',
                price: '${cheapest['total_price_egp']} EGP',
                leaveTime: 'Cheapest Route 💰',
                badgeText: 'Cheapest',
                badgeColor: Colors.orange,
                icon: Icons.directions_bus,
                iconColor: const Color(0xFF6C63FF),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailsScreen(routeData: cheapest),
                    ),
                  );
                },
              ),
            if (cheapest != null) const SizedBox(height: 12),

            // 🌟 كارت 3: فايربيز (Ride Sharing) 🌟
            if (sharedRide != null)
              RouteOptionCard(
                title: 'Shared Ride (${sharedRide['driver_id'] ?? 'Driver'})',
                time: '${sharedRide['time_min']} min',
                arrivalTime: 'Direct Route',
                price: '${sharedRide['price_egp']} EGP',
                leaveTime: '${sharedRide['available_seats']} seats left',
                badgeText: 'Comfortable',
                badgeColor: const Color(0xFF6C63FF),
                icon: Icons.directions_car, 
                iconColor: const Color(0xFF6C63FF),
                onTap: () => _navigateToNextPage(context, 'Ride'),
              ),

            if (sharedRide == null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.directions_car_outlined,
                          color: Colors.grey, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No shared rides available',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            Text(
                              'Check back later',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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

// ════════════════════════════════════════════
// كارت المسار 
// ════════════════════════════════════════════
class RouteOptionCard extends StatelessWidget {
  final String title;
  final String time;
  final String arrivalTime;
  final String price;
  final String leaveTime;
  final String badgeText;
  final Color badgeColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap; 
  
  const RouteOptionCard({
    super.key,
    required this.title,
    required this.time,
    required this.arrivalTime,
    required this.price,
    required this.leaveTime,
    required this.badgeText,
    required this.badgeColor,
    required this.icon,
    required this.iconColor,
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
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: badgeColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(color: badgeColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Arrival $arrivalTime',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    leaveTime,
                    style: TextStyle(color: badgeColor, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// صفحة حجز تجريبية للرايد شيرينج
// ════════════════════════════════════════════
class NextPage extends StatelessWidget {
  final String optionName;

  const NextPage({super.key, required this.optionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking $optionName'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Text(
          'You selected $optionName!\nProceed to booking...',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// شاشة التفاصيل الديناميكية (المعدلة بالكارت العلوي)
// ════════════════════════════════════════════
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
    final steps = routeData['steps'] as List<dynamic>? ?? [];
    
    // سحب البيانات الإجمالية من الـ JSON اللي راجع من السيرفر
    final totalTime = routeData['total_time_min']?.toString() ?? '--';
    final totalPrice = routeData['total_price_egp']?.toString() ?? '--';
    final totalDist = routeData['total_distance_km']?.toString() ?? '--';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // الكارت العلوي اللي فيه الخلاصة 
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAE8FF),
              borderRadius: BorderRadius.circular(20),
            ),
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

          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('Step by step guide:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),

          // قائمة الخطوات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final style = _getTransportStyle(step['type']);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (style['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(style['icon'] as IconData, color: style['color'] as Color, size: 20),
                    ),
                    title: Text('From ${step['from']} to ${step['to']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text('${step['type']} • ${step['time_min']} min'),
                    trailing: Text('${step['price_egp']} EGP', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF303099))),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// الـ Widget الصغير اللي بيرسم العناصر جوه الكارت العلوي
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF303099), size: 22),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
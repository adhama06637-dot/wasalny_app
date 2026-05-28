import 'package:flutter/material.dart';
import 'Map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Route Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const RouteDetailsScreen(),
    );
  }
}

class RouteDetailsScreen extends StatefulWidget {
  // ✅ بتاخد routeData من Compare Screen
  final Map<String, dynamic> routeData;

  const RouteDetailsScreen({
    super.key,
    this.routeData = const {},
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    // استخرج البيانات من routeData لو موجودة
    final totalTime  = widget.routeData['total_time_min']?.toString()   ?? '40';
    final totalPrice = widget.routeData['total_price_egp']?.toString()  ?? '20';
    final steps      = widget.routeData['steps'] as List<dynamic>?      ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Route Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(totalTime, totalPrice),
            const SizedBox(height: 25),
            const Text(
              "Your Route",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // لو في steps من الـ API اعرضهم ديناميكي
            if (steps.isNotEmpty)
              ...steps.asMap().entries.map((entry) {
                final index = entry.key;
                final step  = entry.value as Map<String, dynamic>;
                return _buildRouteStep(
                  stepNumber: '${index + 1}',
                  iconColor: _getTypeColor(step['type']?.toString() ?? ''),
                  icon:      _getTypeIcon(step['type']?.toString() ?? ''),
                  title:     'Ride ${step['type'] ?? ''}',
                  fromText:  step['from']?.toString() ?? '',
                  toText:    step['to']?.toString() ?? '',
                  time:      '${step['time_min']} min',
                  cost:      '${step['price_egp']} EGP',
                );
              })
            // لو مفيش steps اعرض الهاردكودد القديم
            else ...[
              _buildRouteStep(
                stepNumber: "1",
                iconColor: Colors.blue,
                icon: Icons.directions_bus,
                title: "Ride microbus",
                fromText: "Hyper One Station",
                toText: "Ramses",
                time: "35 min",
                cost: "15 EGP",
              ),
              _buildRouteStep(
                stepNumber: "2",
                iconColor: Colors.deepPurple,
                icon: Icons.airport_shuttle,
                title: "Then ride microbus",
                fromText: "Ramses",
                toText: "Maadi",
                time: "25 min",
                cost: "12 EGP",
              ),
            ],

            _buildFinalStep(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (value) => setState(() => _selectedIndex = value),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: "Ride"),
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // Summary Card مع زرار View on Map
  // ══════════════════════════════════════════════
  Widget _buildSummaryCard(String totalTime, String totalPrice) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.access_time, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Estimated Time",
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text("$totalTime min",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
              Container(height: 40, width: 1, color: Colors.grey.shade300),
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.wallet, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Estimated Cost",
                          style: TextStyle(color: Colors.deepPurple, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text("$totalPrice EGP",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ✅ زرار View Route on Map — مع routeData صح
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return MapScreen(routeData: widget.routeData);
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
              icon: const Icon(Icons.map, color: Colors.blue),
              label: const Text(
                "View Route on Map",
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // بيرجع لون حسب نوع المواصلة
  // ══════════════════════════════════════════════
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'metro':    return Colors.blue;
      case 'bus':      return Colors.green;
      case 'microbus': return Colors.orange;
      default:         return Colors.deepPurple;
    }
  }

  // بيرجع أيقونة حسب نوع المواصلة
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'metro':    return Icons.directions_subway;
      case 'bus':      return Icons.directions_bus;
      case 'microbus': return Icons.airport_shuttle;
      default:         return Icons.directions;
    }
  }

  Widget _buildRouteStep({
    required String stepNumber,
    required Color iconColor,
    required IconData icon,
    required String title,
    required String fromText,
    required String toText,
    required String time,
    required String cost,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: iconColor,
                    child: Icon(icon, color: Colors.white),
                  ),
                  Positioned(
                    left: -8,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: iconColor,
                      child: Text(stepNumber,
                          style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ],
              ),
              Container(
                width: 2,
                height: 120,
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.grey.shade300,
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.grey.withOpacity(.12),
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("from $fromText",
                      style: const TextStyle(color: Colors.blue)),
                  const SizedBox(height: 4),
                  Text("to $toText",
                      style: const TextStyle(color: Colors.deepPurple)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 18),
                      const SizedBox(width: 5),
                      Text(time),
                      const SizedBox(width: 20),
                      const Icon(Icons.wallet, size: 18),
                      const SizedBox(width: 5),
                      Text(cost),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalStep() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
          child: Icon(Icons.flag, color: Colors.white),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.grey.withOpacity(.12),
                )
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("You arrived",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 5),
                    Text("successfully!",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
                Text("🎉", style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
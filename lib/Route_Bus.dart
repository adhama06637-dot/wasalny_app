import 'package:flutter/material.dart';

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
      home: const RouteBusScreen(),
    );
  }
}

class RouteBusScreen extends StatefulWidget {
  const RouteBusScreen({super.key});

  @override
  State<RouteBusScreen> createState() => _RouteBusScreenState();
}

class _RouteBusScreenState extends State<RouteBusScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Route Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 25),
            const Text(
              "Your Route",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            _buildRouteStep(
              stepNumber: "1",
              iconColor: Colors.blue,
              icon: Icons.directions_bus,
              title: "Ride Bus",
              fromText: "Hyper One Station",
              toText: "Ramses",
              time: "45 min",
              cost: "13 EGP",
            ),

            _buildRouteStep(
              stepNumber: "2",
              iconColor: Colors.deepPurple,
              icon: Icons.airport_shuttle,
              title: "Then ride Bus",
              fromText: "Ramses",
              toText: "Maadi",
              time: "30 min",
              cost: "10 EGP",
            ),

            _buildFinalStep(),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car),
            label: "Ride",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF5F6FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.access_time, color: Colors.white),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estimated Time",
                      style: TextStyle(color: Colors.blue, fontSize: 12)),
                  SizedBox(height: 5),
                  Text("1h 15min",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              )
            ],
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          Row(
            children: const [
              CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.wallet, color: Colors.white),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Estimated Cost",
                      style:
                          TextStyle(color: Colors.deepPurple, fontSize: 12)),
                  SizedBox(height: 5),
                  Text("23 EGP",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              )
            ],
          ),
        ],
      ),
    );
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
                      child: Text(
                        stepNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
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
                      style:
                          const TextStyle(color: Colors.deepPurple)),

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
                  )
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    SizedBox(height: 5),
                    Text(
                      "successfully!",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text("🎉", style: TextStyle(fontSize: 24))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
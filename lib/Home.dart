import 'package:flutter/material.dart';
import 'Profile.dart';
import 'Compare_Screen.dart';
import 'api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFCFCFF),
        fontFamily: 'Roboto', 
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedFrom;
  String? _selectedTo;
  List<String> _locations = ['Loading...']; // قايمة مؤقتة لحد ما الداتا تيجي
  int _currentNavIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    final stations = await ApiService.getStations(); // بنكلم السيرفر بتاعك
    if (stations.isNotEmpty && mounted) {
      setState(() {
        _locations = stations;
        _selectedFrom = stations[0]; // بنختار أول محطة افتراضياً
        _selectedTo = stations[1];   // بنختار تاني محطة افتراضياً
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Bar Area
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.menu,
                      color: Color(0xFF4A4A68),
                      size: 28,
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: const NetworkImage(
                        'https://i.pravatar.cc/150?img=5',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Welcome Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome,',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E2D),
                            ),
                          ),
                          // هنا تم تصليح الإيرور بتاع فايربيز والأقواس
                          Row(
                            children: [
                              Text(
                                FirebaseAuth.instance.currentUser?.displayName ?? 
                                FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? 
                                'User',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF303099),
                                ),
                              ),
                              const Text(
                                ' 👋',
                                style: TextStyle(fontSize: 24),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Where would you like to go?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8A8A9E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE8FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.location_on_outlined,
                          size: 50,
                          color: Color(0xFF303099),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),

                // Main Booking Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // From Dropdown
                      const Text(
                        'From',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1E1E2D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LocationDropdownField(
                        value: _selectedFrom,
                        items: _locations,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFrom = newValue;
                          });
                        },
                      ),
                      
                      // Swap Button
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                final temp = _selectedFrom;
                                _selectedFrom = _selectedTo;
                                _selectedTo = temp;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                                color: Colors.white,
                              ),
                              child: const Icon(
                                Icons.swap_vert,
                                color: Color(0xFF303099),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // To Dropdown
                      const Text(
                        'To',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xFF1E1E2D),
                        ),
                      ),
                      const SizedBox(height: 10),
                      LocationDropdownField(
                        value: _selectedTo,
                        items: _locations,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedTo = newValue;
                          });
                        },
                      ),

                      const SizedBox(height: 40),

                      // Find Route Button
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6464CE),
                              Color(0xFF303099),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                       child: ElevatedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Searching for the best routes... 🚀'),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            final compareData = await ApiService.getCompareRoutes(
                              _selectedFrom ?? 'Hyper One Station', 
                              _selectedTo ?? 'Maadi'
                            );

                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CompareScreen(compareData: compareData),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.search, color: Colors.white, size: 24),
                              SizedBox(width: 10),
                              Text(
                                'Find Route',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() {
            _currentNavIndex = index;
          });

          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          }
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 11, 43, 90),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile', 
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'Ride Sharing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home', 
          ),
        ],
      ),
    );
  }
}

// --- Custom Widget for Dropdown Location Inputs ---
class LocationDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const LocationDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F1FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: Color(0xFF5A4FCF),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true, 
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey.shade600,
                ),
                items: items.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(
                      location,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E1E2D),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// File: home.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'Profile.dart';
import 'screens/RideSharing_screen.dart';
import 'Compare_Screen.dart';
import 'api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/my_rides_screen.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    Future<void> _fetchStations() async {
  final stations = await ApiService.getStations();

  if (stations.isNotEmpty && mounted) {
    setState(() {
      _locations = stations;
      _fromValue = stations[0];
      _toValue = stations.length > 1 ? stations[1] : stations[0];
    });
  }
}

String _getFirstName() {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    if (user.displayName != null &&
        user.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }

    if (user.email != null) {
      String name = user.email!.split('@')[0];
      name = name.replaceAll(RegExp(r'[0-9]'), '');

      if (name.isNotEmpty) {
        return name[0].toUpperCase() +
            name.substring(1).toLowerCase();
      }
    }
  }

  return 'User';
}

  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  
 String _fromValue = 'Loading...';
 String _toValue = 'Loading...';

  List<String> _locations = ['Loading...'];

  @override
void initState() {
  super.initState();

  _fetchStations();

  _timer = Timer.periodic(
    const Duration(seconds: 4),
    (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    },
  );
}

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }


  void _swapLocations() {
    setState(() {
      String temp = _fromValue;
      _fromValue = _toValue;
      _toValue = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildBannerSlider(),
              const SizedBox(height: 20),
              _buildTitleAndFavorites(context),
              const SizedBox(height: 15),
              _buildFormCard(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_getFirstName()} 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
            ),
            SizedBox(height: 4),
            Text(
              'Good afternoon!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF6C5DD3)),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

 
  Widget _buildBannerSlider() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildBannerCard();
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) => _buildDot(index: index)),
        ),
      ],
    );
  }


  Widget _buildBannerCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          
          Container(
            width: 70,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Center(
              child: Icon(Icons.traffic_rounded, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.directions_car, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text('Traffic Update', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(radius: 3, backgroundColor: Colors.red),
                          SizedBox(width: 4),
                          Text('Live', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Heavy traffic on\nRamses Street',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text('Expect +15 min delay', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 8 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? const Color(0xFF6C5DD3) : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildTitleAndFavorites(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Where would you like to go?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2D)),
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No favorite places now'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: const [
                Icon(Icons.star_border, color: Color(0xFF6C5DD3), size: 16),
                SizedBox(width: 4),
                Text('Favorites', style: TextStyle(color: Color(0xFF6C5DD3), fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('From', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _fromValue,
            onChanged: (val) => setState(() => _fromValue = val!),
          ),
          
         
          Stack(
            alignment: Alignment.center,
            children: [
              Divider(color: Colors.grey.withOpacity(0.2), thickness: 1, height: 40),
              GestureDetector(
                onTap: _swapLocations,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FE),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.swap_vert, color: Color(0xFF6C5DD3), size: 20),
                ),
              ),
            ],
          ),
          
          const Text('To', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 8),
          _buildDropdownField(
            value: _toValue,
            onChanged: (val) => setState(() => _toValue = val!),
          ),
          
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.history, color: Colors.grey, size: 16),
                  SizedBox(width: 6),
                  Text('Popular Destinations', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Text('View all', style: TextStyle(color: Color(0xFF6C5DD3), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRecentChip('Nasr City'),
              _buildRecentChip('Maadi'),
              _buildRecentChip('Heliopolis'),
            ],
          ),
          const SizedBox(height: 24),
          
          
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
             onPressed: () async {

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Searching for the best routes... 🚀',
      ),
    ),
  );

  final compareData =
      await ApiService.getCompareRoutes(
    _fromValue,
    _toValue,
  );

  if (context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CompareScreen(
          compareData: compareData,
        ),
      ),
    );
  }
},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5DD3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.share_arrival_time_outlined, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Find Route', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(width: 8),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDropdownField({required String value, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: _locations.map((String location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Color(0xFF6C5DD3), size: 20),
                  const SizedBox(width: 12),
                  Text(location, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E1E2D))),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRecentChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF1E1E2D))),
        ],
      ),
    );
  }

  
  Widget _buildBottomNavigationBar() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        // Home
        GestureDetector(
          onTap: () {},
          child: _buildNavItem(
            icon: Icons.home_filled,
            label: 'Home',
            isActive: true,
          ),
        ),

        // Ride Sharing
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RideSharingScreen(),
              ),
            );
          },
          child: _buildNavItem(
            icon: Icons.local_taxi_outlined,
            label: 'Ride Sharing',
            isActive: false,
          ),
        ),
         
         // My Rides
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyRidesScreen(),
      ),
    );
  },
  child: _buildNavItem(
    icon: Icons.list_alt_outlined,
    label: 'My Rides',
    isActive: false,
  ),
),
        // Profile
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilePage(),
              ),
            );
          },
          child: _buildNavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            isActive: false,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? const Color(0xFF6C5DD3) : Colors.grey, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF6C5DD3) : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 4),
          Container(
            width: 20,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF6C5DD3),
              borderRadius: BorderRadius.circular(2),
            ),
          )
        ]
      ],
    );
  }
}
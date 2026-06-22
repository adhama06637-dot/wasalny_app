import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wasalny_app/Home.dart';
import 'package:wasalny_app/Profile.dart';
import 'package:wasalny_app/screens/RideSharing_screen.dart';

import 'app_colors.dart';

class MyRidesScreen extends StatefulWidget {
  final bool showBottomNav;
  const MyRidesScreen({super.key, this.showBottomNav = true});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  int selectedTab = 0;

Stream<QuerySnapshot> getMyBookings() {
 final user = FirebaseAuth.instance.currentUser;
if (user == null) return const Stream.empty();

return FirebaseFirestore.instance
    .collection('bookings')
    .snapshots();
}

 RideStatus _mapStatus(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return RideStatus.completed;
    case 'cancelled':
      return RideStatus.cancelled;
    default:
      return RideStatus.upcoming;
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'My Rides',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        actions: [
  Padding(
    padding: const EdgeInsetsDirectional.only(end: 18),
    child: IconButton(
      icon: const Icon(Icons.notifications_none_rounded),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const NotificationsScreen(),
          ),
        );
      },
    ),
  ),
],

      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: getMyBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          print("Total Docs = ${docs.length}");

for (var doc in docs) {
  print(doc.data());
}

          final rides = docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
return MyRideUi(
  driver: "Booked Ride",
  rating: 0,
  from: data['From'] ?? '',
  to: data['To'] ?? '',
  date: data['Date']?.toDate().toString().split(' ')[0] ?? '',
  time: '',
  price: data['Price'] ?? 0,
  status: _mapStatus(data['Status'] ?? 'Upcoming'),
  avatarColor: const Color(0xFFE8F1FF),
  icon: Icons.person,
);
          }).toList();

          final filtered = selectedTab == 0
              ? rides.where((r) => r.status == RideStatus.upcoming).toList()
              : selectedTab == 1
                  ? rides.where((r) => r.status == RideStatus.completed).toList()
                  : rides.where((r) => r.status == RideStatus.cancelled).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Container(
                height: 40,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _TabButton(
                      text: 'Upcoming',
                      selected: selectedTab == 0,
                      onTap: () => setState(() => selectedTab = 0),
                    ),
                    _TabButton(
                      text: 'Completed',
                      selected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1),
                    ),
                    _TabButton(
                      text: 'Cancelled',
                      selected: selectedTab == 2,
                      onTap: () => setState(() => selectedTab = 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: cardDecoration(radius: 15),
                  child: const Center(
                    child: Text(
                      'No rides in this tab yet',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                ...filtered.map((ride) => MyRideCard(ride: ride)),
            ],
          );
        },
      ),

     bottomNavigationBar: null,
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
        GestureDetector(
          onTap: () {},
          child: _buildNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            isActive: false,
          ),
        ),

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
            icon: Icons.directions_car_outlined,
            label: 'Ride Sharing',
            isActive: false,
          ),
        ),

        GestureDetector(
          onTap: () {},
          child: _buildNavItem(
            icon: Icons.list_alt_outlined,
            label: 'My Rides',
            isActive: true,
          ),
        ),

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
}

/* ================= MODELS ================= */

class MyRideUi {
  final String driver;
  final double rating;
  final String from;
  final String to;
  final String date;
  final String time;
  final int price;
  final RideStatus status;
  final Color avatarColor;
  final IconData icon;

  const MyRideUi({
    required this.driver,
    required this.rating,
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    required this.avatarColor,
    required this.icon,
  });
}

enum RideStatus { upcoming, completed, cancelled }

extension RideStatusMeta on RideStatus {
  String get label =>
      this == RideStatus.upcoming
          ? 'Upcoming'
          : this == RideStatus.completed
              ? 'Completed'
              : 'Cancelled';

  Color get color =>
      this == RideStatus.upcoming
          ? const Color(0xFF149B61)
          : this == RideStatus.completed
              ? const Color(0xFF5B6472)
              : const Color(0xFFE8506E);

  Color get bg =>
      this == RideStatus.upcoming
          ? const Color(0xFFEAFBF2)
          : this == RideStatus.completed
              ? const Color(0xFFF1F2F5)
              : const Color(0xFFFFEEF3);
}

/* ================= CARD ================= */

class MyRideCard extends StatelessWidget {
  final MyRideUi ride;

  const MyRideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ride.avatarColor,
            child: Icon(ride.icon, size: 28, color: const Color(0xFF172033)),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      ride.driver,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(width: 7),
                    const Icon(Icons.star,
                        color: Color(0xFFFFC247), size: 14),
                    Text(' ${ride.rating}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${ride.from} → ${ride.to}',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(ride.date),
                Text(ride.time),
                Text('${ride.price} EGP'),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: ride.status.bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              ride.status.label,
              style: TextStyle(
                color: ride.status.color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

  Widget _buildNavItem({required IconData icon, required String label, required bool isActive}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? AppColors.primary : AppColors.muted),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? AppColors.primary : AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

/* ================= TAB BUTTON ================= */

class _TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? null : Colors.white,
            gradient: selected ? appGradient() : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
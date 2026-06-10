import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../providers/app_provider.dart';
import 'app_colors.dart';

class MyRidesScreen extends StatefulWidget {
  final bool showBottomNav;
  const MyRidesScreen({super.key, this.showBottomNav = true});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final rides = _mergeBookings(provider.bookings);
    final filtered = selectedTab == 0
        ? rides.where((ride) => ride.status == RideStatus.upcoming).toList()
        : selectedTab == 1
            ? rides.where((ride) => ride.status == RideStatus.completed).toList()
            : rides.where((ride) => ride.status == RideStatus.cancelled).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Rides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        actions: const [Padding(padding: EdgeInsetsDirectional.only(end: 18), child: Icon(Icons.notifications_none_rounded))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              _TabButton(text: 'Upcoming', selected: selectedTab == 0, onTap: () => setState(() => selectedTab = 0)),
              _TabButton(text: 'Completed', selected: selectedTab == 1, onTap: () => setState(() => selectedTab = 1)),
              _TabButton(text: 'Cancelled', selected: selectedTab == 2, onTap: () => setState(() => selectedTab = 2)),
            ]),
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: cardDecoration(radius: 15),
              child: const Center(child: Text('No rides in this tab yet', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
            )
          else
            ...filtered.map((ride) => MyRideCard(ride: ride)),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? BottomNavigationBar(
              currentIndex: 1,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.local_taxi), label: 'Rides'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            )
          : null,
    );
  }

  List<MyRideUi> _mergeBookings(List<Booking> bookings) {
    final bookedRides = bookings.map((booking) => MyRideUi(
          driver: 'Booked Ride',
          rating: 0,
          from: booking.start ?? 'Unknown pickup',
          to: booking.end ?? 'Unknown destination',
          date: booking.created_at == null ? '' : booking.created_at!.toIso8601String().split('T').first,
          time: booking.time ?? '',
          price: (booking.cost ?? 0).round(),
          status: booking.status == 'cancelled' ? RideStatus.cancelled : RideStatus.upcoming,
          avatarColor: const Color(0xFFE8F1FF),
          icon: Icons.person,
        ));

    final combined = [...bookedRides];
    final seen = <String>{};
    return combined.where((ride) => seen.add('${ride.driver}-${ride.from}-${ride.to}-${ride.time}-${ride.status.name}')).toList();
  }
}

class MyRideCard extends StatelessWidget {
  final MyRideUi ride;
  const MyRideCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration(radius: 15),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(radius: 22, backgroundColor: ride.avatarColor, child: Icon(ride.icon, color: const Color(0xFF172033), size: 28)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Text(ride.driver, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 7), const Icon(Icons.star, color: Color(0xFFFFC247), size: 14), Text(' ${ride.rating}', style: const TextStyle(fontSize: 12))]),
          const SizedBox(height: 6),
          Text('${ride.from}  →  ${ride.to}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.calendar_today_rounded, text: ride.date),
          _InfoRow(icon: Icons.access_time_rounded, text: ride.time),
          _InfoRow(icon: Icons.attach_money_rounded, text: '${ride.price} EGP'),
        ])),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.only(top: 52),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: ride.status.bg, borderRadius: BorderRadius.circular(8)),
            child: Text(ride.status.label, style: TextStyle(color: ride.status.color, fontSize: 12, fontWeight: FontWeight.w900)),
          ),
        ),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [Icon(icon, size: 16, color: const Color(0xFF172033)), const SizedBox(width: 10), Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]),
      );
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(gradient: selected ? appGradient() : null, borderRadius: BorderRadius.circular(8), color: selected ? null : Colors.white),
          child: Text(text, style: TextStyle(color: selected ? Colors.white : AppColors.text, fontSize: 12, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

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

  const MyRideUi({required this.driver, required this.rating, required this.from, required this.to, required this.date, required this.time, required this.price, required this.status, required this.avatarColor, required this.icon});
}

enum RideStatus { upcoming, completed, cancelled }

extension RideStatusMeta on RideStatus {
  String get label => this == RideStatus.upcoming ? 'Upcoming' : this == RideStatus.completed ? 'Completed' : 'Cancelled';
  Color get color => this == RideStatus.upcoming ? const Color(0xFF149B61) : this == RideStatus.completed ? const Color(0xFF5B6472) : const Color(0xFFE8506E);
  Color get bg => this == RideStatus.upcoming ? const Color(0xFFEAFBF2) : this == RideStatus.completed ? const Color(0xFFF1F2F5) : const Color(0xFFFFEEF3);
}
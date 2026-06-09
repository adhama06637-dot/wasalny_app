import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wasalny_app/Profile.dart';

import '../models/route.dart' as app_route;
import '../providers/app_provider.dart';
import 'app_colors.dart';
import 'live_route_screen.dart';
import 'my_rides_screen.dart';
import 'publish_trip_screen.dart';
import 'Profile.dart';
import 'package:wasalny_app/Home.dart';


double calculatePrice(double distance) {
  double fuelCostPerKm = 2; // سعر البنزين لكل كيلو
  double maintenancePerKm = 1; // تكلفة الصيانة لكل كيلو
  double baseFare = 10; // سعر ثابت

  return baseFare + (fuelCostPerKm + maintenancePerKm) * distance;
}

class RideSharingScreen extends StatefulWidget {
  final bool showBackButton;
  const RideSharingScreen({super.key, this.showBackButton = true});

  @override
  State<RideSharingScreen> createState() => _RideSharingScreenState();
}

class _RideSharingScreenState extends State<RideSharingScreen> {
  late final TextEditingController fromController;
  late final TextEditingController toController;
  final dateController = TextEditingController(text: 'Today, 20 May');
  final timeController = TextEditingController(text: '10:00 AM');

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    fromController = TextEditingController(text: provider.from);
    toController = TextEditingController(text: provider.to);
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final selectedTransport = provider.selectedTransport;
    final rides = provider.filteredRoutes
        .where((route) => selectedTransport == 'all' || route.transport_type == selectedTransport)
        .map(RideInfo.fromRoute)
        .toList();
    final visibleRides = rides;
    final title = selectedTransport == 'bus'
        ? 'Available Buses'
        : selectedTransport == 'microbus'
            ? 'Available Microbuses'
            : 'Available Rides';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishTripScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          _LabeledField(label: 'From', controller: fromController, icon: Icons.location_on_rounded, trailing: Icons.swap_vert_rounded),
          const SizedBox(height: 12),
          _LabeledField(label: 'To', controller: toController, icon: Icons.location_on_rounded, trailing: Icons.swap_vert_rounded),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
  child: GestureDetector(
    onTap: () async {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030),
      );

      if (pickedDate != null) {
        dateController.text =
            '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';

        setState(() {});
      }
    },
    child: AbsorbPointer(
      child: _LabeledField(
        label: 'Date',
        controller: dateController,
        icon: Icons.calendar_today_rounded,
        compact: true,
      ),
    ),
  ),
),
            const SizedBox(width: 14),
            Expanded(
  child: GestureDetector(
    onTap: () async {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        timeController.text =
            pickedTime.format(context);

        setState(() {});
      }
    },
    child: AbsorbPointer(
      child: _LabeledField(
        label: 'Time',
        controller: timeController,
        icon: Icons.access_time_rounded,
        compact: true,
      ),
    ),
  ),
),
          ]),
          const SizedBox(height: 18),
          SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(13)),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Search Rides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                onPressed: () async {
                  final provider = context.read<AppProvider>();
                  if (fromController.text.trim().isEmpty || toController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter From and To locations')));
                    return;
                  }
                  await provider.searchRoutes(from: fromController.text, to: toController.text, transport: provider.selectedTransport);
                  if (mounted) setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
            const Icon(Icons.near_me_rounded, color: AppColors.secondary, size: 16),
            const SizedBox(width: 4),
            Text('${visibleRides.length} nearby', style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          if (visibleRides.isEmpty)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: cardDecoration(radius: 15),
              child: Text('No $title found from ${fromController.text} to ${toController.text}. Try another route or transport type.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
            )
          else
            ...visibleRides.map((ride) => RideCard(
                  ride: ride,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride))),
                )),
        ],
      ),
      bottomNavigationBar: const RideBottomNav(currentIndex: 1),
    );
  }
}

class RideDetailsScreen extends StatefulWidget {
  final RideInfo ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  RideType selectedType = RideType.mixed;

  @override
  void initState() {
    super.initState();
    selectedType = widget.ride.type;
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Ride Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        actions: const [Padding(padding: EdgeInsetsDirectional.only(end: 18), child: Icon(Icons.favorite_border_rounded))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          const RideMap(height: 132),
          const SizedBox(height: 22),
          Row(children: [
            _DriverAvatar(ride: ride, radius: 28),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(ride.driver, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(width: 8), const Icon(Icons.star, color: Color(0xFFFFC247), size: 15), Text(' ${ride.rating}', style: const TextStyle(fontSize: 13))]),
              const SizedBox(height: 5),
              Text(ride.car, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            ])),
            Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFFF4EEFF), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.phone_rounded, color: AppColors.secondary)),
          ]),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(radius: 14),
            child: Column(children: [
              _DetailLine(dotColor: AppColors.secondary, title: 'From', value: ride.from, trailing: ride.time),
              _DetailLine(dotColor: const Color(0xFFFF4B4B), title: 'To', value: ride.to, trailing: ride.arrival),
              _DetailLine(icon: Icons.calendar_today_rounded, title: 'Date', value: ride.date),
              _DetailLine(icon: Icons.attach_money_rounded, title: 'Price', value: '${ride.price} EGP', valueColor: AppColors.secondary),
              _DetailLine(icon: Icons.airline_seat_recline_normal_rounded, title: 'Seats Left', value: '${ride.seatsLeft} seats left', valueColor: Colors.green),
            ]),
          ),
          const SizedBox(height: 24),
          const Text('Ride Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: RideTypeButton(type: RideType.female, selected: selectedType == RideType.female, onTap: () => setState(() => selectedType = RideType.female))),
            const SizedBox(width: 12),
            Expanded(child: RideTypeButton(type: RideType.male, selected: selectedType == RideType.male, onTap: () => setState(() => selectedType = RideType.male))),
            const SizedBox(width: 12),
            Expanded(child: RideTypeButton(type: RideType.mixed, selected: selectedType == RideType.mixed, onTap: () => setState(() => selectedType = RideType.mixed))),
          ]),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(13)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
                onPressed: () => _bookRide(context, ride),
                child: const Text('Book Ride', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RideBottomNav(currentIndex: 1),
    );
  }

  Future<void> _bookRide(BuildContext context, RideInfo ride) async {
    final provider = context.read<AppProvider>();
    provider.selectRoute(ride.toRoute());
    await provider.bookSelectedRoute();
    if (!context.mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingConfirmedScreen(ride: ride)));
  }
}

class BookingConfirmedScreen extends StatelessWidget {
  final RideInfo ride;
  const BookingConfirmedScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text('Trip Confirmed! 🎉', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(22)),
          child: const Column(children: [
            CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.check_rounded, color: AppColors.primary, size: 42)),
            SizedBox(height: 14),
            Text('Trip Confirmed! 🎉', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            Text("You're all set for the ride.", style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(16), decoration: cardDecoration(radius: 18), child: Row(children: [
          _DriverAvatar(ride: ride, radius: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(ride.driver, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 4), const Icon(Icons.verified, color: AppColors.primary, size: 16)]),
            Text('${ride.rating} ★ • ${ride.car}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          IconButton(onPressed: () => _snack(context, 'Calling ${ride.driver}...'), icon: const Icon(Icons.phone, color: AppColors.primary)),
        ])),
        const SizedBox(height: 12),
        Container(padding: const EdgeInsets.all(16), decoration: cardDecoration(radius: 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Pickup Point', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(children: [const Icon(Icons.location_on_outlined, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(ride.from)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveRouteScreen())), child: const Text('View on Map'))]),
          const Divider(),
          _DialogInfo(icon: Icons.access_time_rounded, text: 'Pickup time  ${ride.time}'),
          _DialogInfo(icon: Icons.attach_money_rounded, text: '${ride.price} EGP paid on pickup'),
        ])),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _snack(context, 'Message sent to driver'), icon: const Icon(Icons.phone), label: const Text('Contact Driver'))),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveRouteScreen())), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('Show Live Route'))),
        ]),
      ]),
      bottomNavigationBar: const RideBottomNav(currentIndex: 1),
    );
  }

  void _snack(BuildContext context, String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}

class BookingSuccessDialog extends StatelessWidget {
  final RideInfo ride;
  const BookingSuccessDialog({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context))),
          Center(child: Container(width: 58, height: 58, decoration: BoxDecoration(color: const Color(0xFF23B768), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.green.withOpacity(.22), blurRadius: 16)]), child: const Icon(Icons.check_rounded, color: Colors.white, size: 38))),
          const SizedBox(height: 22),
          const Center(child: Text('Your seat has been booked!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
          const SizedBox(height: 24),
          Text(ride.driver, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Text(ride.route, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _DialogInfo(icon: Icons.calendar_today_rounded, text: ride.date),
          _DialogInfo(icon: Icons.access_time_rounded, text: ride.time),
          _DialogInfo(icon: Icons.attach_money_rounded, text: '${calculatePrice(ride.distanceKm).toStringAsFixed(0)} EGP'),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(10)),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MyRidesScreen()));
                },
                child: const Text('View My Rides', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final RideInfo ride;
  final VoidCallback onTap;
  const RideCard({super.key, required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: cardDecoration(radius: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _DriverAvatar(ride: ride),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(ride.driver, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(width: 7), const Icon(Icons.star, color: Color(0xFFFFC247), size: 14), Text(' ${ride.rating}', style: const TextStyle(fontSize: 12))]),
              const SizedBox(height: 6),
              Text(ride.route, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(children: [const Icon(Icons.directions_car_filled_outlined, size: 16), const SizedBox(width: 8), Text('Today, ${ride.time}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${ride.price} EGP', style: const TextStyle(color: AppColors.secondary, fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('${ride.seatsLeft} seat${ride.seatsLeft == 1 ? '' : 's'} left', style: TextStyle(color: ride.seatsLeft == 1 ? Colors.red : Colors.green, fontSize: 12, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              RideTypeChip(type: ride.type),
            ]),
          ]),
        ),
      ),
    );
  }
}

class RideBottomNav extends StatelessWidget {
  final int currentIndex;
  const RideBottomNav({super.key, required this.currentIndex});

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.secondary : Colors.grey,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.secondary : Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          // Home
          GestureDetector(
          onTap: () {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
    (route) => false,
  );
},
            child: _buildNavItem(
              icon: Icons.home_filled,
              label: 'Home',
              isActive: currentIndex == 0,
            ),
          ),

          // Ride Sharing
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const RideSharingScreen(
                    showBackButton: false,
                  ),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.local_taxi_outlined,
              label: 'Ride Sharing',
              isActive: currentIndex == 1,
            ),
          ),

          // My Rides
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyRidesScreen(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.list_alt_outlined,
              label: 'My Rides',
              isActive: currentIndex == 2,
            ),
          ),

          // Profile
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
            child: _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isActive: currentIndex == 3,
            ),
          ),
        ],
      ),
    );
  }
}

class RideInfo {
  final String id;
  final String driver;
  final String route;
  final String from;
  final String to;
  final String date;
  final String time;
  final String arrival;
  final double distanceKm;
  final int price;
  final int seatsLeft;
  final RideType type;
  final double rating;
  final String car;
  final Color avatarColor;
  final IconData avatarIcon;

  const RideInfo({required this.id, required this.driver, required this.route, required this.from, required this.to, required this.date, required this.time, required this.arrival, required this.distanceKm, required this.price, required this.seatsLeft, required this.type, required this.rating, required this.car, required this.avatarColor, required this.avatarIcon});

  factory RideInfo.fromRoute(app_route.Route route) {
    final female = route.female_only;
    final driver = route.driver_name ?? 'Driver';
    return RideInfo(
      id: route.id,
      driver: driver,
      route: '${route.start} → ${route.end}',
      from: route.start,
      to: route.end,
      date: DateTime.now().toIso8601String().split('T').first,
      time: route.time,
      arrival: '~${route.time}',
      distanceKm: ((route.cost - 10) / 3).clamp(1, 100).toDouble(),
      price: route.cost.round(),
      seatsLeft: route.available_seats ?? 2,
      type: female ? RideType.female : RideType.mixed,
      rating: route.driver_rating ?? 0,
      car: route.car_model ?? 'Car details unavailable',
      avatarColor: female ? const Color(0xFFFFEEF4) : const Color(0xFFE8F1FF),
      avatarIcon: female ? Icons.person_2 : Icons.person,
    );
  }

  app_route.Route toRoute() => app_route.Route(id: id, start: from, end: to, time: time, cost: price.toDouble(), transfers: 0, transport_type: 'ride_share', driver_name: driver, driver_rating: rating, car_model: car, available_seats: seatsLeft, total_seats: seatsLeft, female_only: type == RideType.female);
}

class _PassengerRow extends StatelessWidget {
  final String name;
  final String seat;
  const _PassengerRow(this.name, this.seat);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)), const SizedBox(width: 10), Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w700))), Chip(label: Text(seat), visualDensity: VisualDensity.compact)]),
      );
}

enum RideType { female, male, mixed }

extension RideTypeMeta on RideType {
  String get label => this == RideType.female ? 'Female' : this == RideType.male ? 'Male' : 'Mixed';
  IconData get icon => this == RideType.female ? Icons.female_rounded : this == RideType.male ? Icons.male_rounded : Icons.groups_2_outlined;
  Color get color => this == RideType.female ? const Color(0xFFE84B72) : this == RideType.male ? AppColors.primary : AppColors.secondary;
  Color get bg => this == RideType.female ? const Color(0xFFFFF0F4) : this == RideType.male ? const Color(0xFFF1F4FF) : const Color(0xFFF6F0FF);
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final IconData? trailing;
  final bool compact;
  const _LabeledField({required this.label, required this.controller, required this.icon, this.trailing, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(left: 4, bottom: 5), child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 12, fontWeight: FontWeight.w700))),
      SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: compact ? 13 : 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            suffixIcon: trailing == null ? null : Icon(trailing, color: AppColors.secondary, size: 20),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ),
    ]);
  }
}

class _DriverAvatar extends StatelessWidget {
  final RideInfo ride;
  final double radius;
  const _DriverAvatar({required this.ride, this.radius = 22});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: radius, backgroundColor: ride.avatarColor, child: Icon(ride.avatarIcon, color: const Color(0xFF172033), size: radius + 6));
  }
}

class RideTypeChip extends StatelessWidget {
  final RideType type;
  const RideTypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: type.bg, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(type.icon, color: type.color, size: 15), const SizedBox(width: 4), Text(type.label, style: TextStyle(color: type.color, fontSize: 11, fontWeight: FontWeight.w800))]),
    );
  }
}

class RideTypeButton extends StatelessWidget {
  final RideType type;
  final bool selected;
  final VoidCallback onTap;
  const RideTypeButton({super.key, required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: type.bg, borderRadius: BorderRadius.circular(12), border: selected ? Border.all(color: AppColors.secondary, width: 1.5) : null),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(type.icon, color: type.color), const SizedBox(width: 5), Text(type.label, style: TextStyle(color: type.color, fontWeight: FontWeight.w900))]),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData? icon;
  final Color? dotColor;
  final String title;
  final String value;
  final String? trailing;
  final Color? valueColor;
  const _DetailLine({this.icon, this.dotColor, required this.title, required this.value, this.trailing, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 24, child: icon == null ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle))) : Icon(icon, size: 18, color: const Color(0xFF1D2638))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, color: AppColors.muted, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(value, style: TextStyle(color: valueColor ?? AppColors.text, fontWeight: FontWeight.w900))])),
        if (trailing != null) Text(trailing!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _DialogInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DialogInfo({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Icon(icon, size: 18), const SizedBox(width: 12), Text(text, style: const TextStyle(fontWeight: FontWeight.w600))]));
}

class RideMap extends StatelessWidget {
  final double height;
  const RideMap({super.key, this.height = 132});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: height,
        color: const Color(0xFFEDEFF4),
        child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = Colors.white.withOpacity(.75)..strokeWidth = 1;
    for (double x = -size.width; x < size.width * 2; x += 28) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), grid);
    }
    for (double y = 10; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 18), grid);
    }

    final path = Path()
      ..moveTo(size.width * .23, size.height * .28)
      ..cubicTo(size.width * .35, size.height * .70, size.width * .48, size.height * .45, size.width * .59, size.height * .62)
      ..cubicTo(size.width * .69, size.height * .78, size.width * .78, size.height * .55, size.width * .88, size.height * .50);
    final routePaint = Paint()..color = AppColors.secondary..strokeWidth = 2.2..style = PaintingStyle.stroke;
    canvas.drawPath(path, routePaint);
    _pin(canvas, Offset(size.width * .22, size.height * .24), AppColors.secondary);
    _pin(canvas, Offset(size.width * .88, size.height * .47), const Color(0xFFFF3B3B));
  }

  void _pin(Canvas canvas, Offset p, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(p, 10, paint);
    canvas.drawCircle(p, 4, Paint()..color = Colors.white);
    final triangle = Path()..moveTo(p.dx - 5, p.dy + 7)..lineTo(p.dx + 5, p.dy + 7)..lineTo(p.dx, p.dy + 20)..close();
    canvas.drawPath(triangle, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
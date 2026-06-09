import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../api_service.dart' as station_api;
import '../providers/app_provider.dart';
import 'Ride_screen.dart';
import 'app_colors.dart';
import 'filter_screen.dart';
import 'my_rides_screen.dart';
import 'profile.dart';
import 'publish_trip_screen.dart';
import 'safety_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _fallbackAreas = ['October', 'Maadi', 'Nasr City', 'Sheikh Zayed', 'Dokki', 'Mohandessin'];

  List<String> _areas = _fallbackAreas;
  final _fromController = TextEditingController(text: 'October');
  final _toController = TextEditingController(text: 'Maadi');
  String _transport = 'ride_share';
  bool _loadingStations = false;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _loadStations() async {
    setState(() => _loadingStations = true);
    final stations = await station_api.ApiService.getStations();
    if (!mounted) return;
    if (stations.length >= 2) {
      setState(() {
        _areas = stations;
        _fromController.text = stations.first;
        _toController.text = stations[1];
        _loadingStations = false;
      });
    } else {
      setState(() => _loadingStations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final userName = provider.currentUser?.name.trim().isNotEmpty == true ? provider.currentUser!.name.trim() : 'User';
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppColors.bg,
      drawer: const _HomeDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          children: [
            Row(children: [
              IconButton(onPressed: () => scaffoldKey.currentState?.openDrawer(), icon: const Icon(Icons.menu_rounded, color: AppColors.text)),
              const Spacer(),
              IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none_rounded, color: AppColors.secondary)),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: const CircleAvatar(radius: 20, child: Icon(Icons.person)),
              ),
            ]),
            const SizedBox(height: 14),
            Text('Welcome, ${_firstName(userName)} 👋', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 4),
            const Text('Where are you going today?', style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(radius: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label('From'),
                _LocationTextField(controller: _fromController, suggestions: _areas),
                Center(
                  child: IconButton.filledTonal(
                    onPressed: () => setState(() {
                      final temp = _fromController.text;
                      _fromController.text = _toController.text;
                      _toController.text = temp;
                    }),
                    icon: const Icon(Icons.swap_vert_rounded, color: AppColors.secondary),
                  ),
                ),
                _label('To'),
                _LocationTextField(controller: _toController, suggestions: _areas),
                const SizedBox(height: 18),
                const Text('Choose your ride type', style: TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _RideTypeCard(label: 'Microbus', icon: Icons.directions_bus_rounded, selected: _transport == 'microbus', onTap: () => setState(() => _transport = 'microbus'))),
                  const SizedBox(width: 10),
                  Expanded(child: _RideTypeCard(label: 'Bus', icon: Icons.airport_shuttle_rounded, selected: _transport == 'bus', onTap: () => setState(() => _transport = 'bus'))),
                  const SizedBox(width: 10),
                  Expanded(child: _RideTypeCard(label: 'Share Ride', icon: Icons.directions_car_filled_rounded, selected: _transport == 'ride_share', onTap: () => setState(() => _transport = 'ride_share'))),
                ]),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(gradient: appGradient(), borderRadius: BorderRadius.circular(15)),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: provider.isLoading || _loadingStations ? null : () => _findRoute(context),
                      child: Text(provider.isLoading ? 'Searching...' : 'Find Ride', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: cardDecoration(radius: 18),
              child: Row(children: [
                const CircleAvatar(backgroundColor: Color(0xFFEFF4FF), child: Icon(Icons.directions_car_filled_rounded, color: AppColors.primary)),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Have a private car trip?', style: TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 3),
                  Text('Publish your ride and share seats with riders going your way.', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                ])),
                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PublishTripScreen())), child: const Text('Create')),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _findRoute(BuildContext context) async {
    final provider = context.read<AppProvider>();
    provider.setTransport(_transport);
    await provider.searchRoutes(from: _fromController.text.trim(), to: _toController.text.trim(), transport: _transport);
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const RidesScreen(showBackButton: true)));
  }

  String _firstName(String value) => value.split(RegExp(r'\s+')).first;

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
      );
}

class _HomeDrawer extends StatelessWidget {
  const _HomeDrawer();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().currentUser;
    final name = user?.name.trim().isNotEmpty == true ? user!.name.trim() : 'User';
    final email = user?.email.trim().isNotEmpty == true ? user!.email.trim() : 'user@wasalny.com';

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
                      Text(email, style: const TextStyle(color: AppColors.muted, fontSize: 12), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text('Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _MenuItem(icon: Icons.add_circle_outline_rounded, title: 'Create Private Car Ride', onTap: () => _menuNavigate(context, const PublishTripScreen())),
            _MenuItem(icon: Icons.directions_car_filled_outlined, title: 'Find Ride', onTap: () => _menuNavigate(context, const RidesScreen(showBackButton: true))),
            _MenuItem(icon: Icons.history_rounded, title: 'My Rides', onTap: () => _menuNavigate(context, const MyRidesScreen())),
            _MenuItem(icon: Icons.account_balance_wallet_outlined, title: 'Wallet', onTap: () => _menuNavigate(context, const WalletScreen())),
            _MenuItem(icon: Icons.person_outline_rounded, title: 'Profile', onTap: () => _menuNavigate(context, const ProfileScreen())),
            _MenuItem(icon: Icons.tune_rounded, title: 'Filters', onTap: () => _menuNavigate(context, const FilterScreen())),
            _MenuItem(icon: Icons.health_and_safety_outlined, title: 'Women Safety', onTap: () => _menuNavigate(context, const SafetyScreen())),
          ],
        ),
      ),
    );
  }

  void _menuNavigate(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.08), child: Icon(icon, color: AppColors.primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      );
}

class _LocationTextField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;

  const _LocationTextField({required this.controller, required this.suggestions});

  @override
  Widget build(BuildContext context) => Autocomplete<String>(
        initialValue: TextEditingValue(text: controller.text),
        optionsBuilder: (value) {
          final text = value.text.trim().toLowerCase();
          if (text.isEmpty) return suggestions;
          return suggestions.where((area) => area.toLowerCase().contains(text));
        },
        onSelected: (value) => controller.text = value,
        fieldViewBuilder: (context, textController, focusNode, onSubmitted) {
          if (textController.text != controller.text) textController.text = controller.text;
          textController.addListener(() => controller.text = textController.text);
          return TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: 'Type location',
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade200)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          );
        },
      );
}

class _RideTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RideTypeCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade200, width: selected ? 1.5 : 1),
          ),
          child: Column(children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.secondary, size: 30),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: selected ? AppColors.primary : AppColors.text)),
          ]),
        ),
      );
}
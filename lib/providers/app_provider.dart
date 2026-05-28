import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/route.dart' as app_route;
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/ride_service.dart';

class AppProvider extends ChangeNotifier {
  final ApiService api = ApiService();
  final RideService rideService = RideService();

  User? currentUser;
  int currentIndex = 0;
  bool isLoading = false;

  List<app_route.Route> routes = [];
  List<app_route.Route> filteredRoutes = [];
  app_route.Route? selectedRoute;
  app_route.Route? lastPublishedRoute;
  List<Booking> bookings = [];
  final Map<String, List<Booking>> rideRequestsByRoute = {};
  int walletBalance = 250;

  String from = 'October';
  String to = 'Maadi';
  String selectedTransport = 'ride_share';
  bool femaleOnly = false;
  double maxPrice = 1000;

  void setCurrentUser(User user) {
    currentUser = user;
    bookings = [];
    notifyListeners();
    loadBookings();
  }

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Future<void> loginOrRegister({required String name, required String email, String? phone}) async {
    currentUser = User(id: email.trim().isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : email.trim(), name: name, email: email, phone: phone);
    bookings = [];
    notifyListeners();
    await loadBookings();
  }

  void setTransport(String type) {
    selectedTransport = type;
    notifyListeners();
  }

  void setRideFilters({bool? femaleOnly, double? maxPrice}) {
    this.femaleOnly = femaleOnly ?? this.femaleOnly;
    this.maxPrice = maxPrice ?? this.maxPrice;
    notifyListeners();
  }

  Future<void> searchRoutes({required String from, required String to, String? transport}) async {
    this.from = from;
    this.to = to;
    selectedTransport = transport ?? selectedTransport;
    isLoading = true;
    notifyListeners();

    final apiRoutes = await api.getRoutes(from: from, to: to, transport: selectedTransport);
    final firestoreRides = await rideService.getRides();
    final firestoreRoutes = firestoreRides.map(app_route.Route.fromJson).where((route) {
      final startMatches = from.trim().isEmpty || route.start.toLowerCase().contains(from.trim().toLowerCase());
      final endMatches = to.trim().isEmpty || route.end.toLowerCase().contains(to.trim().toLowerCase());
      return startMatches && endMatches;
    }).toList();
    routes = [...apiRoutes];
    for (final route in firestoreRoutes) {
      if (!routes.any((item) => item.id == route.id)) routes.add(route);
    }
    final matchedRoutes = routes.where((route) {
      final matchType = selectedTransport == 'all' || route.transport_type == selectedTransport;
      final matchFemale = !femaleOnly || route.female_only;
      final matchPrice = route.cost <= maxPrice;
      return matchType && matchFemale && matchPrice;
    }).toList();
    filteredRoutes = matchedRoutes;

    isLoading = false;
    notifyListeners();
  }

  void selectRoute(app_route.Route route) {
    selectedRoute = route;
    notifyListeners();
  }

  Future<Booking?> bookSelectedRoute() async {
    if (currentUser == null || selectedRoute == null) return null;
    isLoading = true;
    notifyListeners();

    final booking = await api.createBooking(currentUser!.id, selectedRoute!.id) ??
        Booking(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          user_id: currentUser!.id,
          route_id: selectedRoute!.id,
          status: 'requested',
          payment_status: 'pending',
          start: selectedRoute!.start,
          end: selectedRoute!.end,
          time: selectedRoute!.time,
          cost: selectedRoute!.cost,
          created_at: DateTime.now(),
        );
    bookings.insert(0, booking);
    rideRequestsByRoute.putIfAbsent(selectedRoute!.id, () => []);
    final requests = rideRequestsByRoute[selectedRoute!.id]!;
    if (!requests.any((request) => request.id == booking.id)) {
      requests.insert(0, booking);
    }

    isLoading = false;
    notifyListeners();
    return booking;
  }

  Future<void> loadBookings() async {
    if (currentUser == null) return;
    isLoading = true;
    notifyListeners();
    bookings = await api.getUserBookings(currentUser!.id);
    isLoading = false;
    notifyListeners();
  }

  void payBooking(Booking booking) {
    booking.payment_status = 'paid';
    if (booking.cost != null) walletBalance -= booking.cost!.round();
    notifyListeners();
  }

  void cancelBooking(Booking booking) {
    booking.status = 'cancelled';
    notifyListeners();
  }

  Future<bool> publishRoute(app_route.Route route) async {
    isLoading = true;
    notifyListeners();
    app_route.Route? createdRoute;
    try {
      createdRoute = await api.createRoute(route).timeout(const Duration(seconds: 8));
    } catch (_) {
      createdRoute = null;
    }
    createdRoute ??= await rideService.createRide(route);
    final publishedRoute = createdRoute ?? route;
    lastPublishedRoute = publishedRoute;
    selectedRoute = publishedRoute;
    _upsertRoute(publishedRoute);
    rideRequestsByRoute.putIfAbsent(publishedRoute.id, () => []);
    isLoading = false;
    notifyListeners();
    return true;
  }

  List<Booking> getRequestsForRoute(String routeId) => List.unmodifiable(rideRequestsByRoute[routeId] ?? []);

  void approveRideRequest(String routeId, Booking request) {
    request.status = 'approved';
    notifyListeners();
  }

  void rejectRideRequest(String routeId, Booking request) {
    request.status = 'rejected';
    notifyListeners();
  }

  void _upsertRoute(app_route.Route route) {
    routes.removeWhere((item) => item.id == route.id);
    filteredRoutes.removeWhere((item) => item.id == route.id);
    routes.insert(0, route);
    final matchType = selectedTransport == 'all' || route.transport_type == selectedTransport;
    final matchFemale = !femaleOnly || route.female_only;
    final matchPrice = route.cost <= maxPrice;
    if (matchType && matchFemale && matchPrice) filteredRoutes.insert(0, route);
  }

  void topUpWallet(int amount) {
    walletBalance += amount;
    notifyListeners();
  }

}
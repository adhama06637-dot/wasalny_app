import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/route.dart' as app_route;

class RideService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ==========================
  // GET ALL RIDES
  // ==========================

  Future<List<Map<String, dynamic>>> getRides() async {

    try {

      QuerySnapshot snapshot =
          await _firestore
              .collection('rides')
              .get();

      return snapshot.docs.map((doc) {

        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

      }).toList();

    } catch (e) {
      print("Error getting rides: $e");
      return [];
    }
  }

  Future<app_route.Route?> createRide(app_route.Route route) async {
    try {
      final doc = await _firestore.collection('rides').add({
        ...route.toCreateJson(),
        'from': route.start,
        'to': route.end,
        'price_egp': route.cost,
        'seats_left': route.available_seats,
        'driver': route.driver_name,
        'car': route.car_model,
        'created_at': FieldValue.serverTimestamp(),
      });

      return app_route.Route(
        id: doc.id,
        start: route.start,
        end: route.end,
        time: route.time,
        cost: route.cost,
        transfers: route.transfers,
        transport_type: route.transport_type,
        driver_name: route.driver_name,
        driver_rating: route.driver_rating,
        car_model: route.car_model,
        available_seats: route.available_seats,
        total_seats: route.total_seats,
        female_only: route.female_only,
        status: route.status,
      );
    } catch (e) {
      print("Create ride error: $e");
      return null;
    }
  }

  // ==========================
  // CALCULATE PRICE
  // ==========================
double calculateRidePrice({
  required double distanceKm,
}) {

  // البنزين لكل كيلو
  double fuelCostPerKm = 2.5;

  // صيانة ثابتة
  double maintenanceFee = 5;

  // عمولة بسيطة للتطبيق
  double appFee = 3;

  // الحساب النهائي
  double totalPrice =
      (distanceKm * fuelCostPerKm)
      + maintenanceFee
      + appFee;

  return totalPrice;
}

  // ==========================
  // CREATE BOOKING
  // ==========================

  Future<void> createBooking({
    required String userId,
    required String rideId,
    required double price,
  }) async {

    try {

      await _firestore
          .collection('bookings')
          .add({

        "user_id": userId,
        "ride_id": rideId,
        "price_egp": price,
        "status": "booked",
        "created_at": Timestamp.now(),

      });

    } catch (e) {
      print("Booking error: $e");
    }
  }

  // ==========================
  // UPDATE AVAILABLE SEATS
  // ==========================

  Future<void> updateSeats({
    required String rideId,
    required int currentSeats,
  }) async {

    try {

      await _firestore
          .collection('rides')
          .doc(rideId)
          .update({

        "available_seats":
            currentSeats - 1

      });

    } catch (e) {
      print("Seats update error: $e");
    }
  }

  // ==========================
  // GET BOOKINGS
  // ==========================

  Future<List<Map<String, dynamic>>>
  getUserBookings(String userId) async {

    try {

      QuerySnapshot snapshot =
          await _firestore
              .collection('bookings')
              .where(
                'user_id',
                isEqualTo: userId,
              )
              .get();

      return snapshot.docs.map((doc) {

        return {
          "id": doc.id,
          ...doc.data() as Map<String, dynamic>,
        };

      }).toList();

    } catch (e) {

      print("Bookings error: $e");
      return [];
    }
  }
}

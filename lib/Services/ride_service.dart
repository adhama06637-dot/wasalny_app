git pull
import 'package:cloud_firestore/cloud_firestore.dart';

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

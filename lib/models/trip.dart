import 'user.dart';

enum TripType { microbus, bus, car }

class Trip {
  String id;
  String driverId;
  String driverName;
  double driverRating;
  TripType type;
  String from;
  String to;
  String fromStation;
  String toStation;
  DateTime departureTime;
  double price;
  int availableSeats;
  int totalSeats;
  List<String> stops;
  bool isActive;
  String? carModel;
  String? carPlate;

  Trip({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.driverRating,
    required this.type,
    required this.from,
    required this.to,
    required this.fromStation,
    required this.toStation,
    required this.departureTime,
    required this.price,
    required this.availableSeats,
    required this.totalSeats,
    required this.stops,
    this.isActive = true,
    this.carModel,
    this.carPlate,
  });
}
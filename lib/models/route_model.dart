class RouteModel {
  String id;
  String start;
  String end;
  String time;
  double cost;
  int transfers;
  String? driverName;
  double? driverRating;
  String? carModel;
  int? availableSeats;
  int? totalSeats;
  bool isFemaleOnly;
  String? status;

  RouteModel({
    required this.id,
    required this.start,
    required this.end,
    required this.time,
    required this.cost,
    required this.transfers,
    this.driverName,
    this.driverRating,
    this.carModel,
    this.availableSeats,
    this.totalSeats,
    this.isFemaleOnly = false,
    this.status,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'].toString(),
      start: json['start'],
      end: json['end'],
      time: json['time'],
      cost: (json['cost'] as num).toDouble(),
      transfers: json['transfers'],
      driverName: json['driver_name'],
      driverRating: json['driver_rating'] != null ? (json['driver_rating'] as num).toDouble() : null,
      carModel: json['car_model'],
      availableSeats: json['available_seats'],
      totalSeats: json['total_seats'],
      isFemaleOnly: json['is_female_only'] ?? false,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start,
      'end': end,
      'time': time,
      'cost': cost,
      'transfers': transfers,
      'driver_name': driverName,
      'driver_rating': driverRating,
      'car_model': carModel,
      'available_seats': availableSeats,
      'total_seats': totalSeats,
      'is_female_only': isFemaleOnly,
      'status': status,
    };
  }
}

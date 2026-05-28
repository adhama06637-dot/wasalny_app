class Route {
  String id;
  String start;
  String end;
  String time;
  double cost;
  int transfers;
  String transport_type; // all / microbus / bus / ride_share

  // UI-only optional fields. Backend can ignore them.
  String? driver_name;
  double? driver_rating;
  String? car_model;
  int? available_seats;
  int? total_seats;
  bool female_only;
  String status;

  Route({
    required this.id,
    required this.start,
    required this.end,
    required this.time,
    required this.cost,
    required this.transfers,
    this.transport_type = 'ride_share',
    this.driver_name,
    this.driver_rating,
    this.car_model,
    this.available_seats,
    this.total_seats,
    this.female_only = false,
    this.status = 'available',
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    final startValue = json['start'] ?? json['from'] ?? json['origin'] ?? json['pickup'];
    final endValue = json['end'] ?? json['to'] ?? json['destination'] ?? json['dropoff'];
    final priceValue = json['cost'] ?? json['price'] ?? json['total_price_egp'] ?? json['price_egp'];
    final timeValue = json['time'] ?? json['departure_time'] ?? json['duration'] ?? json['total_time_min'];
    return Route(
      id: json['id'].toString(),
      start: startValue?.toString() ?? '',
      end: endValue?.toString() ?? '',
      time: timeValue?.toString() ?? '',
      cost: _toDouble(priceValue),
      transfers: _toInt(json['transfers']),
      transport_type: json['transport_type'] ?? json['type'] ?? 'ride_share',
      driver_name: json['driver_name'] ?? json['driver'],
      driver_rating: json['driver_rating'] == null ? null : _toDouble(json['driver_rating']),
      car_model: json['car_model'] ?? json['car'],
      available_seats: _toNullableInt(json['available_seats'] ?? json['seats_left']),
      total_seats: _toNullableInt(json['total_seats'] ?? json['seats']),
      female_only: json['female_only'] ?? json['is_female_only'] ?? json['femaleOnly'] ?? false,
      status: json['status'] ?? 'available',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start,
      'end': end,
      'time': time,
      'cost': cost,
      'transfers': transfers,
      'transport_type': transport_type,
      if (driver_name != null) 'driver_name': driver_name,
      if (driver_rating != null) 'driver_rating': driver_rating,
      if (car_model != null) 'car_model': car_model,
      if (available_seats != null) 'available_seats': available_seats,
      if (total_seats != null) 'total_seats': total_seats,
      'female_only': female_only,
      'status': status,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'start': start,
      'end': end,
      'time': time,
      'cost': cost,
      'transfers': transfers,
      'transport_type': transport_type,
      if (driver_name != null) 'driver_name': driver_name,
      if (driver_rating != null) 'driver_rating': driver_rating,
      if (car_model != null) 'car_model': car_model,
      if (available_seats != null) 'available_seats': available_seats,
      if (total_seats != null) 'total_seats': total_seats,
      'female_only': female_only,
      'status': status,
    };
  }
}
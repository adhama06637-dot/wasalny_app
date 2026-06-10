class Booking {
  String id;
  String user_id;
  String route_id;
  String status; // booked / cancelled
  String payment_status;
  String? user_name;

  // Optional joined route fields for UI display.
  String? start;
  String? end;
  String? time;
  double? cost;
  DateTime? created_at;

  Booking({
    required this.id,
    required this.user_id,
    required this.route_id,
    this.status = 'booked',
    this.payment_status = 'pending',
    this.user_name,
    this.start,
    this.end,
    this.time,
    this.cost,
    this.created_at,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final route = json['route'] is Map<String, dynamic> ? json['route'] as Map<String, dynamic> : null;
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : null;
    return Booking(
      id: json['id'].toString(),
      user_id: json['user_id'].toString(),
      route_id: json['route_id'].toString(),
      status: json['status'] ?? 'booked',
      payment_status: json['payment_status'] ?? 'pending',
      user_name: json['user_name']?.toString() ?? json['name']?.toString() ?? user?['name']?.toString(),
      start: json['start'] ?? json['route_start'] ?? route?['start'] ?? route?['from'],
      end: json['end'] ?? json['route_end'] ?? route?['end'] ?? route?['to'],
      time: json['time'] ?? json['route_time'] ?? route?['time'] ?? route?['departure_time'],
      cost: _toNullableDouble(json['cost'] ?? json['route_cost'] ?? route?['cost'] ?? route?['price']),
      created_at: json['created_at'] == null ? null : DateTime.tryParse(json['created_at']),
    );
  }

  static double? _toNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'route_id': route_id,
      'status': status,
      'payment_status': payment_status,
      if (created_at != null) 'created_at': created_at!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': user_id,
      'route_id': route_id,
    };
  }
}
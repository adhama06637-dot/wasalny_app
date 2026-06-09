class Booking {
  String id;
  String userId;
  String routeId;
  String status; // booked / cancelled
  String paymentStatus; // paid / pending / failed
  DateTime? createdAt;
  DateTime? updatedAt;

  // Related data (populated from backend)
  String? routeStart;
  String? routeEnd;
  String? routeTime;
  double? routeCost;
  String? driverName;

  Booking({
    required this.id,
    required this.userId,
    required this.routeId,
    this.status = 'booked',
    this.paymentStatus = 'pending',
    this.createdAt,
    this.updatedAt,
    this.routeStart,
    this.routeEnd,
    this.routeTime,
    this.routeCost,
    this.driverName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      routeId: json['route_id'].toString(),
      status: json['status'] ?? 'booked',
      paymentStatus: json['payment_status'] ?? 'pending',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      routeStart: json['route_start'],
      routeEnd: json['route_end'],
      routeTime: json['route_time'],
      routeCost: json['route_cost'] != null ? (json['route_cost'] as num).toDouble() : null,
      driverName: json['driver_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'route_id': routeId,
      'status': status,
      'payment_status': paymentStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'route_id': routeId,
    };
  }
}

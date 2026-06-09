enum TransportMode { microbus, bus, car, walk }

class RouteStep {
  String instruction;
  TransportMode mode;
  String? lineNumber;
  String fromStation;
  String toStation;
  double? price;
  int? durationMinutes;

  RouteStep({
    required this.instruction,
    required this.mode,
    this.lineNumber,
    required this.fromStation,
    required this.toStation,
    this.price,
    this.durationMinutes,
  });
}
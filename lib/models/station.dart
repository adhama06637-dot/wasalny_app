class Station {
  String id;
  String name;
  String area;
  double latitude;
  double longitude;
  List<String> lines; // Bus or microbus lines passing through
  String type; // 'microbus', 'bus', 'metro'

  Station({
    required this.id,
    required this.name,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.lines,
    required this.type,
  });
}
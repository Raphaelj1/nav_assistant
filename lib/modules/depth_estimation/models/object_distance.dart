class ObjectDistance {
  final String label;
  final double distance; // in meters

  ObjectDistance({required this.label, required this.distance});

  @override
  String toString() => '$label at ${distance.toStringAsFixed(2)}m';
}
class Vehicle {
  final String vehicleId;
  final String name;
  final String model;
  final int manufactureYear;
  final DateTime vehicleDate;

  Vehicle({
    required this.vehicleId,
    required this.name,
    required this.model,
    required this.manufactureYear,
    required this.vehicleDate,
  });

  // Convert a Vehicle object to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'name': name,
      'model': model,
      'manufactureYear': manufactureYear,
      'vehicleDate': vehicleDate.toIso8601String(),
    };
  }

  // Create a Vehicle object from Firestore data
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleId'],
      name: json['name'],
      model: json['model'],
      manufactureYear: json['manufactureYear'],
      vehicleDate: DateTime.parse(json['vehicleDate']),
    );
  }
}

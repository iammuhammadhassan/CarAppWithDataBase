class Car {
  final int vehicleId;
  final int sellerId;
  final String make;
  final String model;
  final int yearProduced;
  final double price;
  final int mileage;
  final String fuelType;
  final String transmission;
  final String location;
  final String imageUrl;
  final int isInspected;
  final int views;

  Car({
    required this.vehicleId,
    required this.sellerId,
    required this.make,
    required this.model,
    required this.yearProduced,
    required this.price,
    required this.mileage,
    required this.fuelType,
    required this.transmission,
    required this.location,
    required this.imageUrl,
    required this.isInspected,
    required this.views,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      vehicleId: int.tryParse(json['vehicle_id'].toString()) ?? 0,
      sellerId: int.tryParse(json['seller_id'].toString()) ?? 0,
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      // Use tryParse because the JSON is sending "2024" (String)
      yearProduced: int.tryParse(json['year_produced'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      mileage: int.tryParse(json['mileage'].toString()) ?? 0,
      fuelType: json['fuel_type']?.toString() ?? '',
      transmission: json['transmission']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      isInspected: int.tryParse(json['is_inspected'].toString()) ?? 0,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
    );
  }

  String get id => vehicleId.toString();
  String get image => imageUrl;
}

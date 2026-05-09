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
  final String? imageUrl2;
  final String? imageUrl3;
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
    this.imageUrl2,
    this.imageUrl3,
    required this.isInspected,
    required this.views,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    String? readText(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null) {
          final text = value.toString().trim();
          if (text.isNotEmpty && text.toLowerCase() != 'null') {
            return text;
          }
        }
      }

      return null;
    }

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
      imageUrl2: readText(['image_url_2', 'image_url2', 'image2']),
      imageUrl3: readText(['image_url_3', 'image_url3', 'image3']),
      isInspected: int.tryParse(json['is_inspected'].toString()) ?? 0,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
    );
  }

  String get id => vehicleId.toString();
  String get image => imageUrl;
}

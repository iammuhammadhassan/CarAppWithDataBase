class Car {
  final String id;
  final String make;
  final String model;
  final String price;
  final String image;
  final String location;

  Car({
    required this.id, 
    required this.make, 
    required this.model, 
    required this.price, 
    required this.image,
    required this.location,
  });

  // This converts the JSON from your PHP script into a Flutter Car object
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['vehicle_id'].toString(),
      make: json['make'] ?? 'Unknown',
      model: json['model'] ?? '',
      price: json['price'] ?? '0',
      image: json['image_url'] ?? '',
      location: json['location'] ?? 'Pakistan',
    );
  }
}
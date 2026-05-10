class Inquiry {
  final int id;
  final int vehicleId;
  final int buyerId;
  final String message;
  final String carName;
  final String date;

  Inquiry({
    required this.id,
    required this.vehicleId,
    required this.buyerId,
    required this.message,
    required this.carName,
    required this.date,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      vehicleId: json['vehicle_id'] is int
          ? json['vehicle_id']
          : int.tryParse(json['vehicle_id']?.toString() ?? '0') ?? 0,
      buyerId: json['buyer_id'] is int
          ? json['buyer_id']
          : int.tryParse(json['buyer_id']?.toString() ?? '0') ?? 0,
      message: json['message']?.toString() ?? '',
      carName: json['car_name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle_id': vehicleId,
    'buyer_id': buyerId,
    'message': message,
    'car_name': carName,
    'date': date,
  };
}

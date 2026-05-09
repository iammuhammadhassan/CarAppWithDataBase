class UserModel {
  final int? userId;
  final int? sellerId;
  final String fullName;
  final String role;

  const UserModel({
    this.userId,
    this.sellerId,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      sellerId: json['seller_id'] != null
          ? int.tryParse(json['seller_id'].toString())
          : (json['user_id'] != null
                ? int.tryParse(json['user_id'].toString())
                : null),
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? 'buyer').toString().toLowerCase(),
    );
  }
}

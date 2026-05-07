class UserModel {
  final int? userId;
  final String fullName;
  final String role;

  const UserModel({this.userId, required this.fullName, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString())
          : null,
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? 'buyer').toString().toLowerCase(),
    );
  }
}

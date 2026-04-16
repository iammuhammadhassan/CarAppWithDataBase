class UserModel {
  final String fullName;
  final String role;

  const UserModel({required this.fullName, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: (json['full_name'] ?? '').toString(),
      role: (json['role'] ?? 'buyer').toString().toLowerCase(),
    );
  }
}

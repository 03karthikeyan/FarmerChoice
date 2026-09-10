class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // CUSTOMER, FARMER, ADMIN
  final String profileImage;
  final bool isVerified;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.role,
    this.profileImage = '',
    this.isVerified = false,
    this.status = 'ACTIVE',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      profileImage: json['profileImage'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'profileImage': profileImage,
      'isVerified': isVerified,
      'status': status,
    };
  }
}

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String role; // CUSTOMER, FARMER, ADMIN
  final String profileImage;
  final bool isVerified;
  final String status;
  final String villageOrTown;
  final String district;
  final String state;
  final String defaultDeliveryAddress;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email = '',
    required this.role,
    this.profileImage = '',
    this.isVerified = false,
    this.status = 'ACTIVE',
    this.villageOrTown = '',
    this.district = '',
    this.state = 'Tamil Nadu',
    this.defaultDeliveryAddress = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Check if nested profile exists (from login or profile responses)
    final profile = json['profile'] is Map<String, dynamic> ? json['profile'] : null;

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      profileImage: json['profileImage'] ?? '',
      isVerified: json['isVerified'] ?? false,
      status: json['status'] ?? 'ACTIVE',
      villageOrTown: json['villageOrTown'] ?? json['village'] ?? profile?['villageOrTown'] ?? profile?['village'] ?? '',
      district: json['district'] ?? profile?['district'] ?? '',
      state: json['state'] ?? profile?['state'] ?? 'Tamil Nadu',
      defaultDeliveryAddress: json['defaultDeliveryAddress'] ?? profile?['defaultDeliveryAddress'] ?? '',
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
      'villageOrTown': villageOrTown,
      'district': district,
      'state': state,
      'defaultDeliveryAddress': defaultDeliveryAddress,
    };
  }
}

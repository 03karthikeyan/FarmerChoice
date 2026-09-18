class FarmerProfileModel {
  final String id;
  final String userId;
  final String farmName;
  final String village;
  final String taluk;
  final String district;
  final String state;
  final String farmAddress;
  final String aboutMe;
  final double rating;
  final int totalReviews;
  final int completedDealsCount;
  final bool isOrganicCertified;
  final String verificationStatus; // PENDING, VERIFIED, REJECTED
  final List<String> badges;
  final List<String> farmPhotos;
  final String userName;
  final String userPhone;
  final String userProfileImage;
  final bool isVerified;

  FarmerProfileModel({
    required this.id,
    required this.userId,
    this.farmName = '',
    required this.village,
    this.taluk = '',
    required this.district,
    this.state = 'Tamil Nadu',
    this.farmAddress = '',
    this.aboutMe = '',
    this.rating = 5.0,
    this.totalReviews = 0,
    this.completedDealsCount = 0,
    this.isOrganicCertified = true,
    this.verificationStatus = 'PENDING',
    this.badges = const [],
    this.farmPhotos = const [],
    this.userName = '',
    this.userPhone = '',
    this.userProfileImage = '',
    this.isVerified = false,
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    String uId = '';
    String uName = '';
    String uPhone = '';
    String uProfileImage = '';
    bool uVerified = false;

    if (json['userId'] is Map<String, dynamic>) {
      final u = json['userId'];
      uId = u['_id'] ?? u['id'] ?? '';
      uName = u['name'] ?? '';
      uPhone = u['phone'] ?? '';
      uProfileImage = u['profileImage'] ?? '';
      uVerified = u['isVerified'] ?? false;
    } else {
      uId = json['userId'] ?? '';
    }

    return FarmerProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: uId,
      farmName: json['farmName'] ?? '',
      village: json['village'] ?? '',
      taluk: json['taluk'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? 'Tamil Nadu',
      farmAddress: json['farmAddress'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 5.0,
      totalReviews: json['totalReviews'] ?? 0,
      completedDealsCount: json['completedDealsCount'] ?? 0,
      isOrganicCertified: json['isOrganicCertified'] ?? true,
      verificationStatus: json['verificationStatus'] ?? 'PENDING',
      badges: json['badges'] != null ? List<String>.from(json['badges']) : [],
      farmPhotos: json['farmPhotos'] != null ? List<String>.from(json['farmPhotos']) : [],
      userName: uName.isNotEmpty ? uName : (json['userName'] ?? json['farmName'] ?? 'Farmer'),
      userPhone: uPhone,
      userProfileImage: uProfileImage,
      isVerified: uVerified || (json['verificationStatus'] == 'VERIFIED'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'farmName': farmName,
      'village': village,
      'taluk': taluk,
      'district': district,
      'state': state,
      'farmAddress': farmAddress,
      'aboutMe': aboutMe,
      'rating': rating,
      'totalReviews': totalReviews,
      'completedDealsCount': completedDealsCount,
      'isOrganicCertified': isOrganicCertified,
      'verificationStatus': verificationStatus,
      'badges': badges,
      'farmPhotos': farmPhotos,
      'userName': userName,
      'userPhone': userPhone,
      'userProfileImage': userProfileImage,
      'isVerified': isVerified,
    };
  }
}

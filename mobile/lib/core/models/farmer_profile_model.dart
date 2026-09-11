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
  });

  factory FarmerProfileModel.fromJson(Map<String, dynamic> json) {
    return FarmerProfileModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] is Map ? json['userId']['_id'] : (json['userId'] ?? ''),
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
    };
  }
}

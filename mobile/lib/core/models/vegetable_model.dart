import 'user_model.dart';
import 'farmer_profile_model.dart';

class VegetableModel {
  final String id;
  final String name;
  final String tamilName;
  final String category; // Leafy, Root, Vegetable, Other
  final List<String> images;
  final String description;
  final double price;
  final String priceUnit; // kg, bunch, piece
  final double availableQuantity;
  final String availabilityStatus; // AVAILABLE_NOW, LIMITED_STOCK, OUT_OF_STOCK
  final bool isOrganic;
  final String featuredStatus;
  final double minOrderQuantity;
  final int viewCount;
  final int inquiryCount;
  final DateTime? harvestDate;
  final UserModel? farmer;
  final FarmerProfileModel? farmerProfile;

  VegetableModel({
    required this.id,
    required this.name,
    this.tamilName = '',
    this.category = 'Vegetable',
    this.images = const [],
    this.description = '',
    required this.price,
    this.priceUnit = 'kg',
    required this.availableQuantity,
    this.minOrderQuantity = 1.0,
    this.availabilityStatus = 'AVAILABLE_NOW',
    this.isOrganic = true,
    this.featuredStatus = 'NONE',
    this.viewCount = 0,
    this.inquiryCount = 0,
    this.harvestDate,
    this.farmer,
    this.farmerProfile,
  });

  factory VegetableModel.fromJson(Map<String, dynamic> json) {
    UserModel? farmerObj;
    if (json['farmerId'] is Map<String, dynamic>) {
      farmerObj = UserModel.fromJson(json['farmerId']);
    }

    FarmerProfileModel? profileObj;
    if (json['farmerProfileId'] is Map<String, dynamic>) {
      profileObj = FarmerProfileModel.fromJson(json['farmerProfileId']);
    }

    DateTime? parsedHarvestDate;
    if (json['harvestDate'] != null) {
      try {
        parsedHarvestDate = DateTime.parse(json['harvestDate']);
      } catch (_) {}
    }

    return VegetableModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      tamilName: json['tamilName'] ?? '',
      category: json['category'] ?? 'Vegetable',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      priceUnit: json['priceUnit'] ?? 'kg',
      availableQuantity: (json['availableQuantity'] != null)
          ? (json['availableQuantity'] as num).toDouble()
          : 0.0,
      minOrderQuantity: (json['minOrderQuantity'] != null)
          ? (json['minOrderQuantity'] as num).toDouble()
          : 1.0,
      availabilityStatus: json['availabilityStatus'] ?? 'AVAILABLE_NOW',
      isOrganic: json['isOrganic'] ?? true,
      featuredStatus: json['featuredStatus'] ?? 'NONE',
      viewCount: json['viewCount'] ?? 0,
      inquiryCount: json['inquiryCount'] ?? 0,
      harvestDate: parsedHarvestDate,
      farmer: farmerObj,
      farmerProfile: profileObj,
    );
  }
}

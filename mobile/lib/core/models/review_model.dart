import 'user_model.dart';

class ReviewModel {
  final String id;
  final String dealId;
  final String customerId;
  final String farmerId;
  final double rating;
  final String comment;
  final bool isVerifiedDeal;
  final String status;
  final String farmerReply;
  final UserModel? customer;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.dealId,
    required this.customerId,
    required this.farmerId,
    required this.rating,
    required this.comment,
    this.isVerifiedDeal = true,
    this.status = 'PUBLISHED',
    this.farmerReply = '',
    this.customer,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    UserModel? cust;
    if (json['customerId'] is Map<String, dynamic>) {
      cust = UserModel.fromJson(json['customerId']);
    }

    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      dealId: json['dealId'] is Map ? json['dealId']['_id'] : (json['dealId'] ?? ''),
      customerId: cust != null ? cust.id : (json['customerId'] ?? ''),
      farmerId: json['farmerId'] is Map ? json['farmerId']['_id'] : (json['farmerId'] ?? ''),
      rating: (json['rating'] != null) ? (json['rating'] as num).toDouble() : 5.0,
      comment: json['comment'] ?? '',
      isVerifiedDeal: json['isVerifiedDeal'] ?? true,
      status: json['status'] ?? 'PUBLISHED',
      farmerReply: json['farmerReply'] ?? '',
      customer: cust,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

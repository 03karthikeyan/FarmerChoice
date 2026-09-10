import 'user_model.dart';
import 'vegetable_model.dart';

class DealModel {
  final String id;
  final String dealNumber;
  final String customerId;
  final String farmerId;
  final String vegetableId;
  final double requestedQuantity;
  final double agreedQuantity;
  final double requestedPrice;
  final double agreedPrice;
  final String priceUnit;
  final double dealReferenceValue;
  final String deliveryMethod; // PICKUP, DELIVERY, FARM_VISIT
  final String deliveryAddress;
  final String preferredDate;
  final String customerNote;
  final String farmerNote;
  final String status; // REQUESTED, NEGOTIATING, ACCEPTED, READY, COMPLETED, CANCELLED
  final bool customerConfirmed;
  final bool farmerConfirmed;
  final bool hasReview;
  final UserModel? customer;
  final UserModel? farmer;
  final VegetableModel? vegetable;

  DealModel({
    required this.id,
    required this.dealNumber,
    required this.customerId,
    required this.farmerId,
    required this.vegetableId,
    required this.requestedQuantity,
    required this.agreedQuantity,
    required this.requestedPrice,
    required this.agreedPrice,
    this.priceUnit = 'kg',
    required this.dealReferenceValue,
    this.deliveryMethod = 'PICKUP',
    this.deliveryAddress = '',
    this.preferredDate = '',
    this.customerNote = '',
    this.farmerNote = '',
    required this.status,
    this.customerConfirmed = false,
    this.farmerConfirmed = false,
    this.hasReview = false,
    this.customer,
    this.farmer,
    this.vegetable,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    UserModel? cust;
    if (json['customerId'] is Map<String, dynamic>) {
      cust = UserModel.fromJson(json['customerId']);
    }

    UserModel? farm;
    if (json['farmerId'] is Map<String, dynamic>) {
      farm = UserModel.fromJson(json['farmerId']);
    }

    VegetableModel? veg;
    if (json['vegetableId'] is Map<String, dynamic>) {
      veg = VegetableModel.fromJson(json['vegetableId']);
    }

    return DealModel(
      id: json['_id'] ?? json['id'] ?? '',
      dealNumber: json['dealNumber'] ?? 'DEAL',
      customerId: cust != null ? cust.id : (json['customerId'] ?? ''),
      farmerId: farm != null ? farm.id : (json['farmerId'] ?? ''),
      vegetableId: veg != null ? veg.id : (json['vegetableId'] ?? ''),
      requestedQuantity: (json['requestedQuantity'] != null)
          ? (json['requestedQuantity'] as num).toDouble()
          : 1.0,
      agreedQuantity: (json['agreedQuantity'] != null)
          ? (json['agreedQuantity'] as num).toDouble()
          : 1.0,
      requestedPrice: (json['requestedPrice'] != null)
          ? (json['requestedPrice'] as num).toDouble()
          : 0.0,
      agreedPrice: (json['agreedPrice'] != null)
          ? (json['agreedPrice'] as num).toDouble()
          : 0.0,
      priceUnit: json['priceUnit'] ?? 'kg',
      dealReferenceValue: (json['dealReferenceValue'] != null)
          ? (json['dealReferenceValue'] as num).toDouble()
          : 0.0,
      deliveryMethod: json['deliveryMethod'] ?? 'PICKUP',
      deliveryAddress: json['deliveryAddress'] ?? '',
      preferredDate: json['preferredDate']?.toString() ?? '',
      customerNote: json['customerNote'] ?? '',
      farmerNote: json['farmerNote'] ?? '',
      status: json['status'] ?? 'REQUESTED',
      customerConfirmed: json['customerConfirmed'] ?? false,
      farmerConfirmed: json['farmerConfirmed'] ?? false,
      hasReview: json['hasReview'] ?? false,
      customer: cust,
      farmer: farm,
      vegetable: veg,
    );
  }
}

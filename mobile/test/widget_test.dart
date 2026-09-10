import 'package:flutter_test/flutter_test.dart';
import 'package:farmer_choice/core/models/user_model.dart';
import 'package:farmer_choice/core/models/vegetable_model.dart';
import 'package:farmer_choice/core/models/deal_model.dart';
import 'package:farmer_choice/core/models/review_model.dart';

void main() {
  group('Farmer Choice Model Tests', () {
    test('UserModel JSON serialization', () {
      final user = UserModel(
        id: 'u1',
        name: 'Ramesh Kumar',
        phone: '9840123451',
        email: 'ramesh@farm.com',
        role: 'FARMER',
        isVerified: true,
      );

      final json = user.toJson();
      expect(json['name'], 'Ramesh Kumar');
      expect(json['role'], 'FARMER');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson.id, 'u1');
      expect(fromJson.name, 'Ramesh Kumar');
      expect(fromJson.isVerified, true);
    });

    test('VegetableModel JSON parsing', () {
      final json = {
        '_id': 'v1',
        'name': 'Fresh Tomato',
        'tamilName': 'நாட்டு தக்காளி',
        'category': 'Vegetable',
        'price': 25.0,
        'priceUnit': 'kg',
        'availableQuantity': 50.0,
        'availabilityStatus': 'AVAILABLE_NOW',
        'isOrganic': true,
        'featuredStatus': 'APPROVED'
      };

      final veg = VegetableModel.fromJson(json);
      expect(veg.id, 'v1');
      expect(veg.name, 'Fresh Tomato');
      expect(veg.price, 25.0);
      expect(veg.priceUnit, 'kg');
      expect(veg.isOrganic, true);
      expect(veg.featuredStatus, 'APPROVED');
    });

    test('DealModel direct negotiation reference value test', () {
      final json = {
        '_id': 'd1',
        'dealNumber': 'FC1024',
        'customerId': 'c1',
        'farmerId': 'f1',
        'vegetableId': 'v1',
        'requestedQuantity': 10.0,
        'agreedQuantity': 10.0,
        'requestedPrice': 25.0,
        'agreedPrice': 25.0,
        'priceUnit': 'kg',
        'dealReferenceValue': 250.0,
        'status': 'REQUESTED',
        'customerConfirmed': false,
        'farmerConfirmed': false,
      };

      final deal = DealModel.fromJson(json);
      expect(deal.dealNumber, 'FC1024');
      expect(deal.dealReferenceValue, 250.0);
      expect(deal.status, 'REQUESTED');
    });

    test('ReviewModel verified deal validation test', () {
      final json = {
        '_id': 'r1',
        'dealId': 'd1',
        'customerId': 'c1',
        'farmerId': 'f1',
        'rating': 5.0,
        'comment': 'Direct farm fresh vegetables! Highly recommended.',
        'isVerifiedDeal': true,
        'status': 'PUBLISHED',
      };

      final review = ReviewModel.fromJson(json);
      expect(review.rating, 5.0);
      expect(review.isVerifiedDeal, true);
    });
  });
}

import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../network/api_client.dart';

class FarmerProvider extends ChangeNotifier {
  Map<String, dynamic> _stats = {
    'totalProducts': 0,
    'availableProducts': 0,
    'newRequests': 0,
    'activeDeals': 0,
    'completedDeals': 0,
    'rating': 5.0,
    'totalReviews': 0,
    'verificationStatus': 'PENDING'
  };
  List<VegetableModel> _myProducts = [];
  bool _isLoading = false;

  Map<String, dynamic> get stats => _stats;
  List<VegetableModel> get myProducts => _myProducts;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().dio.get('/farmers/dashboard/stats');
      if (res.data['success'] == true) {
        _stats = res.data['data'];
      }
    } catch (e) {
      debugPrint('Error fetching farmer dashboard stats: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyProducts({String status = 'All'}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().dio.get(
        '/vegetables/farmer/my-listings',
        queryParameters: {'status': status},
      );
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _myProducts = list.map((json) => VegetableModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching farmer products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addProduct({
    required String name,
    String tamilName = '',
    required String category,
    required double price,
    String priceUnit = 'kg',
    required double availableQuantity,
    String availabilityStatus = 'AVAILABLE_NOW',
    String description = '',
    List<String> images = const [],
  }) async {
    try {
      final res = await ApiClient().dio.post('/vegetables', data: {
        'name': name.trim(),
        'tamilName': tamilName.trim(),
        'category': category,
        'price': price,
        'priceUnit': priceUnit,
        'availableQuantity': availableQuantity,
        'availabilityStatus': availabilityStatus,
        'description': description.trim(),
        'images': images.isNotEmpty ? images : ['/assets/images/vegetables/default.png'],
      });

      if (res.data['success'] == true) {
        await fetchMyProducts();
        await fetchDashboardStats();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding vegetable: $e');
    }
    return false;
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    String tamilName = '',
    required String category,
    required double price,
    String priceUnit = 'kg',
    required double availableQuantity,
    String availabilityStatus = 'AVAILABLE_NOW',
    String description = '',
    List<String> images = const [],
  }) async {
    try {
      final res = await ApiClient().dio.put('/vegetables/$id', data: {
        'name': name.trim(),
        'tamilName': tamilName.trim(),
        'category': category,
        'price': price,
        'priceUnit': priceUnit,
        'availableQuantity': availableQuantity,
        'availabilityStatus': availabilityStatus,
        'description': description.trim(),
        'images': images.isNotEmpty ? images : ['/assets/images/vegetables/default.png'],
      });

      if (res.data['success'] == true) {
        await fetchMyProducts();
        await fetchDashboardStats();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating vegetable: $e');
    }
    return false;
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final res = await ApiClient().dio.delete('/vegetables/$id');
      if (res.data['success'] == true) {
        _myProducts.removeWhere((p) => p.id == id);
        await fetchDashboardStats();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting vegetable: $e');
    }
    return false;
  }

  Future<bool> quickUpdate({
    required String vegetableId,
    double? price,
    double? availableQuantity,
    String? availabilityStatus,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (price != null) data['price'] = price;
      if (availableQuantity != null) data['availableQuantity'] = availableQuantity;
      if (availabilityStatus != null) data['availabilityStatus'] = availabilityStatus;

      final res = await ApiClient().dio.patch('/vegetables/$vegetableId/quick-update', data: data);

      if (res.data['success'] == true) {
        await fetchMyProducts();
        return true;
      }
    } catch (e) {
      debugPrint('Error quick updating: $e');
    }
    return false;
  }

  Future<bool> requestFeatured(String vegetableId) async {
    try {
      final res = await ApiClient().dio.post('/vegetables/$vegetableId/request-featured');
      if (res.data['success'] == true) {
        await fetchMyProducts();
        return true;
      }
    } catch (e) {
      debugPrint('Error requesting featured: $e');
    }
    return false;
  }
}

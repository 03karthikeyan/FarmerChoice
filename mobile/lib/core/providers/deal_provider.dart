import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/deal_model.dart';
import '../network/api_client.dart';

class DealProvider extends ChangeNotifier {
  List<DealModel> _myDeals = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedTab = 'All';

  List<DealModel> get myDeals => _myDeals;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedTab => _selectedTab;

  List<DealModel> get filteredDeals {
    if (_selectedTab == 'All') return _myDeals;
    return _myDeals.where((d) => d.status.toUpperCase() == _selectedTab.toUpperCase()).toList();
  }

  void setSelectedTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<void> fetchMyDeals({String role = 'customer'}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.get('/deals/my-deals', queryParameters: {'role': role});
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _myDeals = list.map((json) => DealModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Failed to load deals.';
      debugPrint('Error fetching deals: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error fetching deals: $e';
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createDealRequest({
    required String vegetableId,
    required double quantity,
    required double referencePrice,
    required String deliveryMethod,
    String deliveryAddress = '',
    String customerNote = '',
  }) async {
    _errorMessage = '';
    try {
      final res = await ApiClient().dio.post('/deals/request', data: {
        'vegetableId': vegetableId,
        'requestedQuantity': quantity,
        'requestedPrice': referencePrice,
        'deliveryMethod': deliveryMethod,
        'deliveryAddress': deliveryAddress,
        'customerNote': customerNote,
      });

      if (res.data['success'] == true) {
        await fetchMyDeals(role: 'customer');
        return true;
      } else {
        _errorMessage = res.data['message'] ?? 'Failed to submit deal request.';
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data?['message'] ?? e.message ?? 'Server error creating deal request.';
      debugPrint('Error creating deal request: $_errorMessage');
    } catch (e) {
      _errorMessage = 'Error creating deal request: $e';
      debugPrint(_errorMessage);
    }
    notifyListeners();
    return false;
  }

  Future<bool> submitCounterOffer({
    required String dealId,
    required double quantity,
    required double price,
    String note = '',
    String role = 'customer',
  }) async {
    try {
      final res = await ApiClient().dio.post('/deals/$dealId/counter', data: {
        'quantity': quantity,
        'price': price,
        'note': note,
      });

      if (res.data['success'] == true) {
        await fetchMyDeals(role: role);
        return true;
      }
    } catch (e) {
      debugPrint('Error countering deal: $e');
    }
    return false;
  }

  Future<bool> acceptDeal(String dealId, {String role = 'customer'}) async {
    try {
      final res = await ApiClient().dio.post('/deals/$dealId/accept');
      if (res.data['success'] == true) {
        await fetchMyDeals(role: role);
        return true;
      }
    } catch (e) {
      debugPrint('Error accepting deal: $e');
    }
    return false;
  }

  Future<bool> markReady(String dealId) async {
    try {
      final res = await ApiClient().dio.post('/deals/$dealId/ready');
      if (res.data['success'] == true) {
        await fetchMyDeals(role: 'farmer');
        return true;
      }
    } catch (e) {
      debugPrint('Error marking ready: $e');
    }
    return false;
  }

  Future<bool> confirmCompletion(String dealId, {String role = 'customer'}) async {
    try {
      final res = await ApiClient().dio.post('/deals/$dealId/complete');
      if (res.data['success'] == true) {
        await fetchMyDeals(role: role);
        return true;
      }
    } catch (e) {
      debugPrint('Error confirming completion: $e');
    }
    return false;
  }
}

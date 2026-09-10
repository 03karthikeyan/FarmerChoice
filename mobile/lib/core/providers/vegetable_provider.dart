import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../network/api_client.dart';

class VegetableProvider extends ChangeNotifier {
  List<VegetableModel> _allVegetables = [];
  List<VegetableModel> _featuredVegetables = [];
  List<VegetableModel> _filteredVegetables = [];
  List<VegetableModel> _farmerComparisonList = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest';

  List<VegetableModel> get allVegetables => _allVegetables;
  List<VegetableModel> get featuredVegetables => _featuredVegetables;
  List<VegetableModel> get filteredVegetables => _filteredVegetables;
  List<VegetableModel> get farmerComparisonList => _farmerComparisonList;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  VegetableProvider() {
    fetchVegetables();
  }

  Future<void> fetchVegetables() async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await ApiClient().dio.get('/vegetables');
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _allVegetables = list.map((json) => VegetableModel.fromJson(json)).toList();
        _featuredVegetables = _allVegetables.where((v) => v.featuredStatus == 'APPROVED').toList();
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching vegetables: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    List<VegetableModel> results = List.from(_allVegetables);

    if (_selectedCategory != 'All') {
      results = results.where((v) => v.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results = results.where((v) =>
          v.name.toLowerCase().contains(query) ||
          v.tamilName.toLowerCase().contains(query) ||
          v.description.toLowerCase().contains(query)
      ).toList();
    }

    if (_sortBy == 'lowest_price') {
      results.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'highest_price') {
      results.sort((a, b) => b.price.compareTo(a.price));
    }

    _filteredVegetables = results;
  }

  Future<void> compareFarmers(String vegetableName) async {
    try {
      final res = await ApiClient().dio.get('/vegetables/compare/$vegetableName');
      if (res.data['success'] == true) {
        final List list = res.data['data'];
        _farmerComparisonList = list.map((json) => VegetableModel.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error comparing farmers: $e');
    }
  }

  // Farmer: Create Vegetable
  Future<bool> createVegetable(Map<String, dynamic> data) async {
    try {
      final res = await ApiClient().dio.post('/vegetables', data: data);
      if (res.data['success'] == true) {
        await fetchVegetables();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating vegetable: $e');
    }
    return false;
  }

  // Farmer: Update Vegetable
  Future<bool> updateVegetable(String id, Map<String, dynamic> data) async {
    try {
      final res = await ApiClient().dio.put('/vegetables/$id', data: data);
      if (res.data['success'] == true) {
        await fetchVegetables();
        return true;
      }
    } catch (e) {
      debugPrint('Error updating vegetable: $e');
    }
    return false;
  }

  // Farmer: Delete Vegetable
  Future<bool> deleteVegetable(String id) async {
    try {
      final res = await ApiClient().dio.delete('/vegetables/$id');
      if (res.data['success'] == true) {
        _allVegetables.removeWhere((v) => v.id == id);
        _applyFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting vegetable: $e');
    }
    return false;
  }
}

import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../models/farmer_profile_model.dart';
import '../network/api_client.dart';

class VegetableProvider extends ChangeNotifier {
  List<VegetableModel> _allVegetables = [];
  List<VegetableModel> _featuredVegetables = [];
  List<VegetableModel> _filteredVegetables = [];
  List<VegetableModel> _farmerComparisonList = [];
  List<FarmerProfileModel> _nearbyFarmers = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _isLoadingFarmers = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 15;

  // Filter criteria
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'newest'; // newest, lowest_price, highest_price, popular, available_now
  String _selectedDistrict = 'All';
  double? _maxPrice;
  bool _onlyOrganic = false;

  // Getters
  List<VegetableModel> get allVegetables => _allVegetables;
  List<VegetableModel> get featuredVegetables => _featuredVegetables;
  List<VegetableModel> get filteredVegetables => _filteredVegetables;
  List<VegetableModel> get farmerComparisonList => _farmerComparisonList;
  List<FarmerProfileModel> get nearbyFarmers => _nearbyFarmers;

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingFarmers => _isLoadingFarmers;
  bool get hasMore => _hasMore;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get selectedDistrict => _selectedDistrict;
  double? get maxPrice => _maxPrice;
  bool get onlyOrganic => _onlyOrganic;

  VegetableProvider() {
    fetchVegetables();
    fetchNearbyFarmers();
  }

  // Fetch Vegetables with Server Pagination and Filters
  Future<void> fetchVegetables({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'page': _page,
        'limit': _limit,
      };

      if (_selectedCategory != 'All') queryParams['category'] = _selectedCategory;
      if (_searchQuery.trim().isNotEmpty) queryParams['search'] = _searchQuery.trim();
      if (_sortBy != 'newest') queryParams['sortBy'] = _sortBy;
      if (_selectedDistrict != 'All') queryParams['district'] = _selectedDistrict;
      if (_maxPrice != null && _maxPrice! > 0) queryParams['maxPrice'] = _maxPrice;
      if (_onlyOrganic) queryParams['isOrganic'] = 'true';

      final res = await ApiClient().dio.get('/vegetables', queryParameters: queryParams);
      if (res.data['success'] == true) {
        final List list = res.data['data'] ?? [];
        final items = list.map((json) => VegetableModel.fromJson(json)).toList();

        if (refresh || _page == 1) {
          _allVegetables = items;
        } else {
          _allVegetables.addAll(items);
        }

        final int totalPages = res.data['totalPages'] ?? 1;
        _hasMore = _page < totalPages && items.length == _limit;

        _featuredVegetables = _allVegetables.where((v) => v.featuredStatus == 'APPROVED').toList();
        _applyClientFilters();
      }
    } catch (e) {
      debugPrint('Error fetching vegetables: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more pages for infinite scroll
  Future<void> loadMoreVegetables() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _page += 1;
    try {
      final queryParams = <String, dynamic>{
        'page': _page,
        'limit': _limit,
      };

      if (_selectedCategory != 'All') queryParams['category'] = _selectedCategory;
      if (_searchQuery.trim().isNotEmpty) queryParams['search'] = _searchQuery.trim();
      if (_sortBy != 'newest') queryParams['sortBy'] = _sortBy;
      if (_selectedDistrict != 'All') queryParams['district'] = _selectedDistrict;
      if (_maxPrice != null && _maxPrice! > 0) queryParams['maxPrice'] = _maxPrice;
      if (_onlyOrganic) queryParams['isOrganic'] = 'true';

      final res = await ApiClient().dio.get('/vegetables', queryParameters: queryParams);
      if (res.data['success'] == true) {
        final List list = res.data['data'] ?? [];
        final items = list.map((json) => VegetableModel.fromJson(json)).toList();

        _allVegetables.addAll(items);
        final int totalPages = res.data['totalPages'] ?? 1;
        _hasMore = _page < totalPages && items.length == _limit;

        _applyClientFilters();
      }
    } catch (e) {
      debugPrint('Error loading more vegetables: $e');
      _page -= 1;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  // Fetch Nearby / Active Farmers
  Future<void> fetchNearbyFarmers({String? district}) async {
    _isLoadingFarmers = true;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{
        'limit': 10,
        'sortBy': 'rating',
      };
      if (district != null && district != 'All' && district.isNotEmpty) {
        queryParams['district'] = district;
      }

      final res = await ApiClient().dio.get('/farmers', queryParameters: queryParams);
      if (res.data['success'] == true) {
        final List list = res.data['data'] ?? [];
        _nearbyFarmers = list.map((json) => FarmerProfileModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching nearby farmers: $e');
    }

    _isLoadingFarmers = false;
    notifyListeners();
  }

  // Filter Setters
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    fetchVegetables(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchVegetables(refresh: true);
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    fetchVegetables(refresh: true);
  }

  void setDistrict(String district) {
    _selectedDistrict = district;
    fetchVegetables(refresh: true);
    fetchNearbyFarmers(district: district);
  }

  void applyAdvancedFilters({
    String? category,
    String? district,
    double? maxPrice,
    bool? onlyOrganic,
    String? sortBy,
  }) {
    if (category != null) _selectedCategory = category;
    if (district != null) _selectedDistrict = district;
    _maxPrice = maxPrice;
    if (onlyOrganic != null) _onlyOrganic = onlyOrganic;
    if (sortBy != null) _sortBy = sortBy;

    fetchVegetables(refresh: true);
    if (district != null) fetchNearbyFarmers(district: district);
  }

  void resetFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortBy = 'newest';
    _selectedDistrict = 'All';
    _maxPrice = null;
    _onlyOrganic = false;
    fetchVegetables(refresh: true);
    fetchNearbyFarmers();
  }

  void _applyClientFilters() {
    List<VegetableModel> results = List.from(_allVegetables);

    if (_selectedCategory != 'All') {
      results = results.where((v) => v.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }

    if (_onlyOrganic) {
      results = results.where((v) => v.isOrganic).toList();
    }

    if (_maxPrice != null && _maxPrice! > 0) {
      results = results.where((v) => v.price <= _maxPrice!).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results = results.where((v) =>
          v.name.toLowerCase().contains(query) ||
          v.tamilName.toLowerCase().contains(query) ||
          v.description.toLowerCase().contains(query)).toList();
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
        final List list = res.data['data'] ?? [];
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
        await fetchVegetables(refresh: true);
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
        await fetchVegetables(refresh: true);
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
        _applyClientFilters();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting vegetable: $e');
    }
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/farmer_profile_model.dart';
import '../network/api_client.dart';
import '../storage/storage_service.dart';
import '../socket/socket_service.dart';

enum AuthState { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  FarmerProfileModel? _farmerProfile;
  AuthState _state = AuthState.initial;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  FarmerProfileModel? get farmerProfile => _farmerProfile;
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isFarmer => _currentUser?.role == 'FARMER';
  bool get isCustomer => _currentUser?.role == 'CUSTOMER';

  AuthProvider() {
    checkAuthSession();
  }

  Future<void> checkAuthSession() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final cachedUser = await StorageService().getUser();
      final token = await StorageService().getAccessToken();

      if (token != null && token.isNotEmpty && cachedUser != null) {
        _currentUser = UserModel.fromJson(cachedUser);

        // Restore cached farmer profile if role is FARMER
        if (_currentUser?.role == 'FARMER') {
          final cachedProfile = await StorageService().getFarmerProfile();
          if (cachedProfile != null) {
            _farmerProfile = FarmerProfileModel.fromJson(cachedProfile);
          }
        }

        _state = AuthState.authenticated;
        SocketService().connect();
        notifyListeners();

        // Silently refresh profile in background if farmer
        if (_currentUser?.role == 'FARMER') {
          _refreshFarmerProfileSilently();
        }
        return;
      }
    } catch (e) {
      debugPrint('Check session error: $e');
    }

    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  Future<void> _refreshFarmerProfileSilently() async {
    try {
      final res = await ApiClient().dio.get('/farmers/profile');
      if (res.data['success'] == true && res.data['data'] != null) {
        final profileData = res.data['data']['profile'] ?? res.data['data'];
        if (profileData is Map<String, dynamic>) {
          _farmerProfile = FarmerProfileModel.fromJson(profileData);
          await StorageService().saveFarmerProfile(_farmerProfile!.toJson());
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Silent profile refresh skipped: $e');
    }
  }

  Future<bool> login(String identifier, String password) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.post('/auth/login', data: {
        'identifier': identifier.trim(),
        'password': password.trim(),
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        _currentUser = UserModel.fromJson(data['user']);

        if (data['profile'] != null && _currentUser!.role == 'FARMER') {
          _farmerProfile = FarmerProfileModel.fromJson(data['profile']);
          await StorageService().saveFarmerProfile(_farmerProfile!.toJson());
        }

        await StorageService().saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        await StorageService().saveUser(_currentUser!.toJson());

        _state = AuthState.authenticated;
        SocketService().connect();
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e, 'Login failed. Please check credentials.');
    } catch (e) {
      _errorMessage = 'Connection error: $e';
    }

    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  String _parseDioError(DioException e, String defaultMsg) {
    if (e.response?.data is Map && e.response?.data['message'] != null) {
      return e.response!.data['message'].toString();
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check if server is reachable.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Unable to connect to server (${ApiClient.baseUrl}).';
    }
    return defaultMsg;
  }

  Future<bool> registerCustomer({
    required String name,
    required String phone,
    String email = '',
    required String password,
    required String villageOrTown,
    required String district,
    String state = 'Tamil Nadu',
    String profileImage = '',
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.post('/auth/register', data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'role': 'CUSTOMER',
        'villageOrTown': villageOrTown.trim(),
        'district': district.trim(),
        'state': state,
        'profileImage': profileImage,
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        _currentUser = UserModel.fromJson(data['user']);
        await StorageService().saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        await StorageService().saveUser(_currentUser!.toJson());

        _state = AuthState.authenticated;
        SocketService().connect();
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e, 'Registration failed.');
    } catch (e) {
      _errorMessage = 'Registration error: $e';
    }

    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<bool> registerFarmer({
    required String name,
    required String phone,
    String email = '',
    required String password,
    required String farmName,
    required String village,
    String taluk = '',
    required String district,
    String state = 'Tamil Nadu',
    required String farmAddress,
    String aboutMe = '',
    String profileImage = '',
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.post('/auth/register', data: {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password.trim(),
        'role': 'FARMER',
        'farmName': farmName.trim(),
        'village': village.trim(),
        'taluk': taluk.trim(),
        'district': district.trim(),
        'state': state,
        'farmAddress': farmAddress.trim(),
        'aboutMe': aboutMe.trim(),
        'profileImage': profileImage,
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        _currentUser = UserModel.fromJson(data['user']);
        if (data['profile'] != null) {
          _farmerProfile = FarmerProfileModel.fromJson(data['profile']);
          await StorageService().saveFarmerProfile(_farmerProfile!.toJson());
        }
        await StorageService().saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        await StorageService().saveUser(_currentUser!.toJson());

        _state = AuthState.authenticated;
        SocketService().connect();
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = _parseDioError(e, 'Farmer registration failed.');
    } catch (e) {
      _errorMessage = 'Registration error: $e';
    }

    _state = AuthState.unauthenticated;
    notifyListeners();
    return false;
  }

  // Update Customer Profile
  Future<bool> updateCustomerProfile({
    required String name,
    String email = '',
    required String phone,
    String? profileImage,
    String? villageOrTown,
    String? district,
    String? state,
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.put('/customers/profile', data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        if (profileImage != null) 'profileImage': profileImage,
        if (villageOrTown != null) 'villageOrTown': villageOrTown.trim(),
        if (district != null) 'district': district.trim(),
        if (state != null) 'state': state.trim(),
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        _currentUser = UserModel.fromJson(data['user']);
        await StorageService().saveUser(_currentUser!.toJson());
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Profile update failed.';
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
    }

    _state = AuthState.authenticated;
    notifyListeners();
    return false;
  }

  // Update Farmer Profile
  Future<bool> updateFarmerProfile({
    required String name,
    String email = '',
    required String phone,
    String? profileImage,
    String? farmName,
    String? farmAddress,
    String? village,
    String? taluk,
    String? district,
    String? state,
    String? aboutMe,
    bool? allowFarmVisit,
  }) async {
    _state = AuthState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await ApiClient().dio.put('/farmers/profile', data: {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        if (profileImage != null) 'profileImage': profileImage,
        if (farmName != null) 'farmName': farmName.trim(),
        if (farmAddress != null) 'farmAddress': farmAddress.trim(),
        if (village != null) 'village': village.trim(),
        if (taluk != null) 'taluk': taluk.trim(),
        if (district != null) 'district': district.trim(),
        if (state != null) 'state': state.trim(),
        if (aboutMe != null) 'aboutMe': aboutMe.trim(),
        if (allowFarmVisit != null) 'allowFarmVisit': allowFarmVisit,
      });

      if (res.data['success'] == true) {
        final data = res.data['data'];
        _currentUser = UserModel.fromJson(data['user']);
        if (data['profile'] != null) {
          _farmerProfile = FarmerProfileModel.fromJson(data['profile']);
          await StorageService().saveFarmerProfile(_farmerProfile!.toJson());
        }
        await StorageService().saveUser(_currentUser!.toJson());
        _state = AuthState.authenticated;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Farmer profile update failed.';
    } catch (e) {
      _errorMessage = 'Error updating farmer profile: $e';
    }

    _state = AuthState.authenticated;
    notifyListeners();
    return false;
  }

  // Delete Account (Farmer or Customer)
  Future<bool> deleteAccount() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final endpoint = isFarmer ? '/farmers/account' : '/customers/account';
      final res = await ApiClient().dio.delete(endpoint);

      if (res.data['success'] == true) {
        await logout();
        return true;
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? 'Account deletion failed.';
    } catch (e) {
      _errorMessage = 'Error deleting account: $e';
    }

    _state = AuthState.authenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await StorageService().clearAll();
    SocketService().disconnect();
    _currentUser = null;
    _farmerProfile = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }
}

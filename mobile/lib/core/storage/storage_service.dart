import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {}
  }

  // Tokens
  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    try {
      await _secureStorage.write(key: 'access_token', value: accessToken);
      await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    } catch (_) {}
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setString('access_token', accessToken);
      await _prefs?.setString('refresh_token', refreshToken);
    } catch (_) {}
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: 'access_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getString('access_token');
    } catch (_) {
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _secureStorage.read(key: 'refresh_token');
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getString('refresh_token');
    } catch (_) {
      return null;
    }
  }

  // Cached User & Role
  Future<void> saveUser(Map<String, dynamic> userJson) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('cached_user', jsonEncode(userJson));
      if (userJson.containsKey('role')) {
        await _prefs!.setString('user_role', userJson['role']);
      }
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getUser() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final data = _prefs?.getString('cached_user');
      if (data != null && data.isNotEmpty) {
        return jsonDecode(data);
      }
    } catch (_) {}
    return null;
  }

  // Cached Farmer Profile
  Future<void> saveFarmerProfile(Map<String, dynamic> profileJson) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('cached_farmer_profile', jsonEncode(profileJson));
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getFarmerProfile() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final data = _prefs?.getString('cached_farmer_profile');
      if (data != null && data.isNotEmpty) {
        return jsonDecode(data);
      }
    } catch (_) {}
    return null;
  }

  Future<String?> getUserRole() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs?.getString('user_role');
    } catch (_) {}
    return null;
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (_) {}
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.remove('cached_user');
      await _prefs?.remove('cached_farmer_profile');
      await _prefs?.remove('user_role');
      await _prefs?.remove('access_token');
      await _prefs?.remove('refresh_token');
    } catch (_) {}
  }
}

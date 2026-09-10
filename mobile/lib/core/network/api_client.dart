import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  // Server Host IP for local machine / Wi-Fi connected devices
  static const String serverHost = '192.168.1.38:5000';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    } else {
      return 'http://$serverHost/api/v1';
    }
  }

  static String get socketUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      return 'http://$serverHost';
    }
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService().getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle session expiry
            await StorageService().clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }
}

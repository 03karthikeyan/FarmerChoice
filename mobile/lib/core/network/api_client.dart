import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio dio;

  // Set to true to use the live cloud backend (https://farmerchoice.onrender.com)
  static const bool isProduction = true;

  // Live Cloud Server on Render
  static const String liveServerHost = 'farmerchoice.onrender.com';
  // Local Development Server (Wi-Fi IP or localhost)
  static const String localServerHost = '192.168.1.38:5000';

  static String get baseUrl {
    if (isProduction) {
      return 'https://$liveServerHost/api/v1';
    } else if (kIsWeb) {
      return 'http://localhost:5000/api/v1';
    } else {
      return 'http://$localServerHost/api/v1';
    }
  }

  static String get socketUrl {
    if (isProduction) {
      return 'https://$liveServerHost';
    } else if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      return 'http://$localServerHost';
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

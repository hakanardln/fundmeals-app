import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        sendTimeout: AppConstants.apiTimeout,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        contentType: 'application/json',
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token != null) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // Auth APIs
  Future<Response> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        AppConstants.registerEndpoint,
        data: userData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post(AppConstants.logoutEndpoint);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // User APIs
  Future<Response> getProfile() async {
    try {
      final response = await _dio.get(AppConstants.profileEndpoint);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(AppConstants.profileEndpoint, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> deleteAccount() async {
    try {
      final response = await _dio.delete(AppConstants.profileEndpoint);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // Store APIs
  Future<Response> getStores({
    int page = 1,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': AppConstants.itemsPerPage,
      };
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.storesEndpoint,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // Product APIs
  Future<Response> getProducts({
    int page = 1,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': AppConstants.itemsPerPage,
      };
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        AppConstants.productsEndpoint,
        queryParameters: queryParams,
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> getProductDetail(int id) async {
    try {
      final response = await _dio.get('${AppConstants.productsEndpoint}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  // Order APIs
  Future<Response> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post(
        AppConstants.ordersEndpoint,
        data: orderData,
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> getOrders({int page = 1}) async {
    try {
      final response = await _dio.get(
        AppConstants.ordersEndpoint,
        queryParameters: <String, dynamic>{
          'page': page,
          'per_page': AppConstants.itemsPerPage,
        },
      );
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> getOrderDetail(int id) async {
    try {
      final response = await _dio.get('${AppConstants.ordersEndpoint}/$id');
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> getOrderTracking(int id) async {
    try {
      final endpoint = AppConstants.orderTrackingEndpoint.replaceAll('{id}', id.toString());
      final response = await _dio.get(endpoint);
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  Future<Response> cancelOrder(int id) async {
    try {
      final response = await _dio.post('${AppConstants.ordersEndpoint}/$id/cancel');
      return response;
    } on DioException catch (e) {
      throw _handleException(e);
    }
  }

  String _handleException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check if the server is running.';
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        }
        return 'Server returned an error (${e.response?.statusCode})';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'An unexpected error occurred: ${e.message}';
      default:
        return 'An error occurred.';
    }
  }
}

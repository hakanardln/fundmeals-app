class AppConstants {
  // API Base URL
  static const String apiBaseUrl = 'https://fundmeals.ours.web.id/api';
  
  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String logoutEndpoint = '/auth/logout';
  static const String profileEndpoint = '/user/profile';
  static const String productsEndpoint = '/products';
  static const String storesEndpoint = '/stores';
  static const String ordersEndpoint = '/orders';
  static const String orderTrackingEndpoint = '/orders/{id}/tracking';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // App Settings
  static const String appName = 'FundMeals';
  static const String appVersion = '1.0.0';
  
  // Timeout Duration
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Pagination
  static const int itemsPerPage = 10;
}

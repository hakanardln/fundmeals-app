import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  bool _requires2FA = false;
  bool _requiresEmailOtp = false;
  int? _pendingUserId;
  String? _twoFactorSecret;

  AuthProvider(this._apiService) {
    _initialize();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  bool get requires2FA => _requires2FA;
  bool get requiresEmailOtp => _requiresEmailOtp;
  int? get pendingUserId => _pendingUserId;
  String? get twoFactorSecret => _twoFactorSecret;

  // Initialize from stored data
  void _initialize() {
    _token = StorageService.getToken();
    final userData = StorageService.getUserData();
    _isLoggedIn = StorageService.isLoggedIn();
    
    if (_token != null && userData != null) {
      _apiService.setToken(_token!);
      _user = User.fromJson(userData);
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['requires_2fa'] == true) {
          _requires2FA = true;
          _pendingUserId = data['user_id'];
          _isLoading = false;
          notifyListeners();
          return true; // Indicates success, but requires 2FA step next
        }

        _requires2FA = false;
        _pendingUserId = null;
        
        _token = data['token'] ?? data['access_token'];
        _user = User.fromJson(data['user'] ?? data['data']);
        _isLoggedIn = true;

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUserData(_user!.toJson());
        await StorageService.setLoggedIn(true);

        _apiService.setToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Login failed';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Verify 2FA
  Future<bool> verify2FA(String otp) async {
    if (_pendingUserId == null) {
      _error = 'Session expired. Please login again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.verify2fa(_pendingUserId!, otp);
      
      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'] ?? data['access_token'];
        _user = User.fromJson(data['user'] ?? data['data']);
        _isLoggedIn = true;
        _requires2FA = false;
        _requiresEmailOtp = false;
        _pendingUserId = null;

        // Save to storage
        await StorageService.saveToken(_token!);
        await StorageService.saveUserData(_user!.toJson());
        await StorageService.setLoggedIn(true);

        _apiService.setToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Invalid OTP code';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register
  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['requires_email_otp'] == true) {
          _requiresEmailOtp = true;
          _token = data['token'] ?? data['access_token'];
          _user = User.fromJson(data['user'] ?? data['data']);
          _apiService.setToken(_token!);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Registration failed';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Verify Email OTP
  Future<bool> verifyEmailOtp(String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.verifyEmailOtp(otp);
      
      if (response.statusCode == 200) {
        _requiresEmailOtp = false;
        _isLoggedIn = true; // Complete the login process

        // Save to storage
        if (_token != null && _user != null) {
          await StorageService.saveToken(_token!);
          await StorageService.saveUserData(_user!.toJson());
          await StorageService.setLoggedIn(true);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Invalid OTP code';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Resend Email OTP
  Future<bool> resendEmailOtp() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.resendEmailOtp();
      
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to resend OTP';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.forgotPassword(email);
      
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to send reset link';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Reset Password
  Future<bool> resetPassword(String email, String otp, String password, String passwordConfirmation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.resetPassword(email, otp, password, passwordConfirmation);
      
      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to reset password';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    }

    _user = null;
    _token = null;
    _isLoggedIn = false;
    _requires2FA = false;
    _requiresEmailOtp = false;
    _pendingUserId = null;
    _error = null;

    _apiService.clearToken();
    await StorageService.clearToken();
    await StorageService.clearUserData();
    await StorageService.setLoggedIn(false);

    _isLoading = false;
    notifyListeners();
  }

  // Enable 2FA
  Future<bool> enable2FA() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.enable2fa();
      if (response.statusCode == 200) {
        _twoFactorSecret = response.data['secret'];
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to enable 2FA';
    } catch (e) {
      _error = 'An error occurred while enabling 2FA';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Disable 2FA
  Future<bool> disable2FA() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.disable2fa();
      if (response.statusCode == 200) {
        _twoFactorSecret = null;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to disable 2FA';
    } catch (e) {
      _error = 'An error occurred while disabling 2FA';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Delete Account
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.deleteAccount();
      if (response.statusCode == 200) {
        // Clear local state
        _user = null;
        _token = null;
        _isLoggedIn = false;
        
        _apiService.clearToken();
        await StorageService.clearToken();
        await StorageService.clearUserData();
        await StorageService.setLoggedIn(false);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e is String ? e : 'Terjadi kesalahan saat menghapus akun.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Get Profile
  Future<bool> getProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getProfile();
      
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data'] ?? response.data);
        await StorageService.saveUserData(_user!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e is String ? e : 'Failed to load profile';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.updateProfile(data);
      
      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['data'] ?? response.data);
        await StorageService.saveUserData(_user!.toJson());
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = e is String ? e : 'Failed to update profile';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
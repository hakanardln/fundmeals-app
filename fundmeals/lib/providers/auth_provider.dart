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

  AuthProvider(this._apiService) {
    _initialize();
  }

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

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
    _error = null;

    _apiService.clearToken();
    await StorageService.clearToken();
    await StorageService.clearUserData();
    await StorageService.setLoggedIn(false);

    _isLoading = false;
    notifyListeners();
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
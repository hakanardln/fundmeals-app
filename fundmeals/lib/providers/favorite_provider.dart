import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/store_model.dart';
import '../services/api_service.dart';

class FavoriteProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  List<Store> _favorites = [];
  bool _isLoading = false;
  String? _error;

  FavoriteProvider(this._apiService);

  List<Store> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getFavorites();
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        _favorites = data.map((item) => Store.fromJson(item['store'])).toList();
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load favorites';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> toggleFavorite(int storeId) async {
    try {
      final response = await _apiService.toggleFavorite(storeId);
      
      if (response.statusCode == 200) {
        final isFavorite = response.data['is_favorite'] == true;
        if (!isFavorite) {
          _favorites.removeWhere((store) => store.id == storeId);
        } else {
          // Ideally fetch the store details and add it, or just reload favorites
          getFavorites();
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = 'Failed to toggle favorite';
    }
    return false;
  }

  bool isFavorite(int storeId) {
    return _favorites.any((store) => store.id == storeId);
  }
}

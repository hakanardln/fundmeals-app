import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_service.dart';

class ReviewProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  bool _isLoading = false;
  String? _error;

  ReviewProvider(this._apiService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> addReview({
    required int storeId,
    required int rating,
    String? comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.addReview(storeId, rating, comment);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to add review';
    } catch (e) {
      _error = 'An error occurred';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }
}

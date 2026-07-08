import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/store_model.dart';
import '../services/api_service.dart';

class StoreProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Store> _stores = [];
  List<Store> _filteredStores = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedCategory;
  String _searchQuery = '';

  StoreProvider(this._apiService);

  // Getters
  List<Store> get stores => _filteredStores.isEmpty && _searchQuery.isEmpty && _selectedCategory == null ? _stores : _filteredStores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Get all stores
  Future<void> getStores({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _stores.clear();
      _filteredStores.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getStores(
        page: _currentPage,
        category: _selectedCategory,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> storesList = data['data'] ?? [];
        
        final newStores = storesList
            .map((s) => Store.fromJson(s as Map<String, dynamic>))
            .toList();

        if (refresh) {
          _stores = newStores;
        } else {
          _stores.addAll(newStores);
        }

        _hasMore = newStores.length >= 10;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
        return;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load stores';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Load more stores
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    
    _currentPage++;
    await getStores();
  }

  // Search stores
  void searchStores(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters locally (or backend depending on implementation)
  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredStores = [];
      return;
    }

    _filteredStores = _stores.where((store) {
      final matchesSearch = _searchQuery.isEmpty ||
          store.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          store.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null || store.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }
}

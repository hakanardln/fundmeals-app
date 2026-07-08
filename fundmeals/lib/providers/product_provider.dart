import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedCategory;
  String _searchQuery = '';

  ProductProvider(this._apiService);

  // Getters
  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  // Get all products
  Future<void> getProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts(
        page: _currentPage,
        category: _selectedCategory,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> productsList = data['data'] ?? data['products'] ?? [];
        
        final newProducts = productsList
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();

        if (refresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _hasMore = newProducts.length >= 10;
        _isLoading = false;
        notifyListeners();
        return;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load products';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get product detail
  Future<bool> getProductDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getProductDetail(id);

      if (response.statusCode == 200) {
        _selectedProduct = Product.fromJson(response.data['data'] ?? response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load product';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Load more products
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    
    _currentPage++;
    await getProducts();
  }

  // Search products
  void searchProducts(String query) {
    _searchQuery = query;
    _currentPage = 1;
    _products.clear();
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _currentPage = 1;
    _products.clear();
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    if (_searchQuery.isEmpty && _selectedCategory == null) {
      _filteredProducts = [];
      return;
    }

    _filteredProducts = _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null || product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _currentPage = 1;
    _filteredProducts = [];
    _products.clear();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Order> _orders = [];
  Order? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  OrderProvider(this._apiService);

  // Getters
  List<Order> get orders => _orders;
  Order? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  // Get all orders
  Future<void> getOrders({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _orders.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getOrders(page: _currentPage);

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> ordersList = data['data'] ?? data['orders'] ?? [];
        
        final newOrders = ordersList
            .map((o) => Order.fromJson(o as Map<String, dynamic>))
            .toList();

        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }

        _hasMore = newOrders.length >= 10;
        _isLoading = false;
        notifyListeners();
        return;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load orders';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get order detail
  Future<bool> getOrderDetail(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getOrderDetail(id);

      if (response.statusCode == 200) {
        _selectedOrder = Order.fromJson(response.data['data'] ?? response.data);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load order';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Create order
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createOrder(orderData);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final newOrder = Order.fromJson(response.data['data'] ?? response.data);
        _orders.insert(0, newOrder);
        _selectedOrder = newOrder;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to create order';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Cancel order
  Future<bool> cancelOrder(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.cancelOrder(id);

      if (response.statusCode == 200) {
        final index = _orders.indexWhere((order) => order.id == id);
        if (index >= 0) {
          _orders[index] = Order.fromJson(response.data['data'] ?? response.data);
        }
        if (_selectedOrder?.id == id) {
          _selectedOrder = Order.fromJson(response.data['data'] ?? response.data);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to cancel order';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Get order tracking
  Future<Map<String, dynamic>?> getOrderTracking(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getOrderTracking(id);

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return response.data['data'] ?? response.data;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? 'Failed to load tracking';
    } catch (e) {
      _error = e is String ? e : 'An error occurred: $e';
    }

    _isLoading = false;
    notifyListeners();
    return null;
  }

  // Load more orders
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    
    _currentPage++;
    await getOrders();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected order
  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }
}

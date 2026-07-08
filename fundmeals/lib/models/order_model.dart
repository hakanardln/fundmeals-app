class Order {
  final int id;
  final int userId;
  final int restaurantId;
  final List<OrderItem> items;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'failed'
  final String? deliveryAddress;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deliveredAt;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    this.deliveryAddress,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deliveredAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      restaurantId: json['restaurant_id'] ?? json['store_id'] ?? 0,
      items: (json['items'] as List?)?.map((item) => OrderItem.fromJson(item)).toList() ?? [],
      totalPrice: (json['total_price'] ?? json['total_amount'] ?? 0).toDouble(),
      status: json['status'] ?? json['order_status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      deliveryAddress: json['delivery_address'],
      notes: json['notes'] ?? json['buyer_notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toString()),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant_id': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'delivery_address': deliveryAddress,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['order_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? (json['product'] != null ? json['product']['name'] : ''),
      productPrice: (json['product_price'] ?? json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_price': productPrice,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }
}

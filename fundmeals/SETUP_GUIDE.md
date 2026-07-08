# FundMeals Flutter Mobile App - Complete Setup Guide

## Persiapan Project

### Requirement yang sudah dipenuhi:
✅ Flutter SDK 3.11.1+  
✅ Structure folder yang rapi  
✅ State management dengan Provider  
✅ HTTP API integration dengan Dio  
✅ Local storage dengan SharedPreferences  
✅ Error handling yang comprehensive  
✅ UI yang menarik dengan Material Design  

## Project Structure

```
fundmeals/
├── lib/
│   ├── constants/
│   │   ├── app_colors.dart           # Color palette
│   │   └── app_constants.dart        # API endpoints & config
│   ├── models/
│   │   ├── user_model.dart           # User data model
│   │   ├── product_model.dart        # Product data model
│   │   └── order_model.dart          # Order data models
│   ├── services/
│   │   ├── api_service.dart          # HTTP API client
│   │   └── storage_service.dart      # Local storage
│   ├── providers/
│   │   ├── auth_provider.dart        # Auth state
│   │   ├── product_provider.dart     # Product state
│   │   ├── cart_provider.dart        # Cart state
│   │   └── order_provider.dart       # Order state
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── orders_screen.dart
│   │   ├── order_detail_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/
│   │   └── common_widgets.dart       # Reusable widgets
│   └── main.dart                     # App entry point
└── pubspec.yaml                      # Dependencies
```

## Fitur yang Sudah Diimplementasikan

### 1. **Authentication**
- Login dengan email & password
- Register user baru
- Auto-login jika token masih valid
- Logout dengan clear token & data
- Profile management (update profile, lihat data user)

### 2. **Product Listing**
- Browse semua products/meals
- Search products by name/description
- Filter by category
- View product details
- Product ratings & reviews

### 3. **Shopping Cart**
- Add/remove items
- Update quantities
- View cart total
- Persistent cart state

### 4. **Order Management**
- Create order from cart
- View order history
- Track order status (pending, confirmed, preparing, ready, delivered)
- View detailed order info
- Cancel orders
- Delivery address management

### 5. **User Profile**
- View/update profile info
- Change address
- Manage contact info
- View order history
- Logout

## Setup Steps

### 1. Install Dependencies
```bash
cd fundmeals
flutter pub get
```

### 2. Update API Configuration
Edit `lib/constants/app_constants.dart`:
```dart
static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
```

### 3. Run the App

**Android:**
```bash
flutter run
```

**iOS:**
```bash
flutter run -d "iPhone"
```

**Web:**
```bash
flutter run -d web
```

## API Integration

Aplikasi ini mengkoneksi ke Laravel backend dengan endpoints berikut:

### Authentication
- `POST /auth/login` - Login user
- `POST /auth/register` - Register user baru
- `POST /auth/logout` - Logout

### User
- `GET /user/profile` - Get user profile
- `PUT /user/profile` - Update profile

### Products
- `GET /products` - List products (dengan pagination)
- `GET /products/{id}` - Get product detail
- Query params: `page`, `per_page`, `category`, `search`

### Orders
- `GET /orders` - List user orders
- `POST /orders` - Create order
- `GET /orders/{id}` - Get order detail
- `POST /orders/{id}/cancel` - Cancel order
- `GET /orders/{id}/tracking` - Get order tracking

## Response Format yang Diharapkan

### Login Response
```json
{
  "token": "your-jwt-token",
  "access_token": "your-jwt-token",
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "1234567890",
    "address": "123 Street",
    "profile_image": "https://...",
    "user_type": "customer",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

### Products Response
```json
{
  "data": [
    {
      "id": 1,
      "name": "Burger Deluxe",
      "description": "...",
      "price": 9.99,
      "image": "https://...",
      "restaurant_id": 1,
      "category": "Burgers",
      "rating": 4.5,
      "review_count": 120,
      "is_available": true,
      "created_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "total": 100,
    "per_page": 10,
    "current_page": 1,
    "last_page": 10
  }
}
```

### Order Response
```json
{
  "data": {
    "id": 1,
    "user_id": 1,
    "restaurant_id": 1,
    "items": [
      {
        "id": 1,
        "order_id": 1,
        "product_id": 1,
        "product_name": "Burger Deluxe",
        "product_price": 9.99,
        "quantity": 2,
        "subtotal": 19.98
      }
    ],
    "total_price": 19.98,
    "status": "pending",
    "payment_status": "paid",
    "delivery_address": "123 Street",
    "notes": "Extra sauce",
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z",
    "delivered_at": null
  }
}
```

## State Management (Provider)

### AuthProvider
```dart
final authProvider = Provider.of<AuthProvider>(context);
authProvider.login(email, password);
authProvider.logout();
authProvider.getProfile();
authProvider.user; // Current user
authProvider.isLoggedIn; // Login status
```

### ProductProvider
```dart
final productProvider = Provider.of<ProductProvider>(context);
productProvider.getProducts();
productProvider.searchProducts(query);
productProvider.filterByCategory(category);
productProvider.getProductDetail(id);
```

### CartProvider
```dart
final cartProvider = Provider.of<CartProvider>(context);
cartProvider.addItem(product, quantity: 1);
cartProvider.removeItem(productId);
cartProvider.updateQuantity(productId, quantity);
cartProvider.increaseQuantity(productId);
cartProvider.decreaseQuantity(productId);
cartProvider.totalPrice; // Total harga
cartProvider.items; // List items di cart
cartProvider.clear(); // Clear cart
```

### OrderProvider
```dart
final orderProvider = Provider.of<OrderProvider>(context);
orderProvider.getOrders();
orderProvider.createOrder(orderData);
orderProvider.getOrderDetail(id);
orderProvider.cancelOrder(id);
```

## Build & Deployment

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### 1. API Connection Error
- Pastikan backend Laravel sudah running
- Check URL di `app_constants.dart`
- Untuk development, gunakan IP address instead of localhost

### 2. Build Error
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### 3. Widget State Issues
```bash
flutter clean
flutter run --no-cache
```

## Testing Tips

### 1. Test Login
- Email: test@example.com
- Password: password123

### 2. Test Product Search
- Ketik di search bar
- Filter by category

### 3. Test Order
- Add items ke cart
- Proceed to checkout
- Lihat order di Orders screen

## Performance Optimization

1. **Image Caching**: Menggunakan `cached_network_image`
2. **Lazy Loading**: Products di-load dengan pagination
3. **State Management**: Provider package untuk efficient rebuilds
4. **HTTP Caching**: Dio interceptor untuk request optimization

## Security Considerations

1. **Token Storage**: JWT token disimpan di SharedPreferences
2. **API Authorization**: Bearer token di setiap request
3. **Input Validation**: Form validation di semua input fields
4. **HTTPS**: Gunakan HTTPS untuk production

## Next Steps

1. Tambahkan payment gateway integration
2. Implement push notifications
3. Tambahkan rating & review feature
4. Tambahkan favorites/wishlist
5. Implement real-time order tracking dengan WebSocket
6. Tambahkan analytics

## Support & Documentation

- Flutter Docs: https://flutter.dev
- Provider Package: https://pub.dev/packages/provider
- Dio HTTP: https://pub.dev/packages/dio

---

**Version**: 1.0.0  
**Last Updated**: June 2024

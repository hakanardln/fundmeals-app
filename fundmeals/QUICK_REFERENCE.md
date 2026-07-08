# 🚀 FundMeals Mobile App - Quick Reference Guide

## 🏃 Quick Start

```bash
# 1. Clone/Navigate to project
cd fundmeals

# 2. Install dependencies
flutter pub get

# 3. Run app
flutter run

# 4. Build APK
flutter build apk --release
```

---

## 🔧 Configuration

### Set Backend API URL
**File**: `lib/constants/app_constants.dart`
```dart
static const String apiBaseUrl = 'http://YOUR_API_URL:8000/api';
```

### Change App Theme
**File**: `lib/constants/app_colors.dart`
- All color constants in one place
- Easy to customize

---

## 📱 App Navigation

```
├── Login Screen
│   └── Register Screen
└── Home Screen (Authenticated)
    ├── Product Listing
    │   └── Product Details
    ├── Cart Screen
    │   └── Checkout
    ├── Orders Screen
    │   └── Order Details
    └── Profile Screen
```

---

## 💾 Key Classes & Usage

### 1. Authentication
```dart
// Access auth state
final authProvider = context.read<AuthProvider>();

// Login
await authProvider.login(email, password);

// Logout
await authProvider.logout();

// Get current user
User? user = authProvider.user;
bool isLoggedIn = authProvider.isLoggedIn;
```

### 2. Products
```dart
final productProvider = context.read<ProductProvider>();

// Get all products
await productProvider.getProducts();

// Search
productProvider.searchProducts(query);

// Filter by category
productProvider.filterByCategory(category);

// Get product detail
await productProvider.getProductDetail(productId);
```

### 3. Shopping Cart
```dart
final cartProvider = context.read<CartProvider>();

// Add item
cartProvider.addItem(product, quantity: 1);

// Remove item
cartProvider.removeItem(productId);

// Update quantity
cartProvider.updateQuantity(productId, 5);

// Get total
double total = cartProvider.totalPrice;
int itemCount = cartProvider.totalQuantity;

// Clear cart
cartProvider.clear();
```

### 4. Orders
```dart
final orderProvider = context.read<OrderProvider>();

// Create order
await orderProvider.createOrder({
  'items': cartProvider.getCartItemsJson(),
  'delivery_address': 'Address here',
  'restaurant_id': 1,
});

// Get orders
await orderProvider.getOrders();

// Get order detail
await orderProvider.getOrderDetail(orderId);

// Cancel order
await orderProvider.cancelOrder(orderId);
```

---

## 🎯 Common Tasks

### Add New API Endpoint
**File**: `lib/services/api_service.dart`
```dart
Future<Response> newEndpoint() async {
  try {
    final response = await _dio.get('/endpoint');
    return response;
  } on DioException catch (e) {
    throw _handleException(e);
  }
}
```

### Add New Screen
1. Create `lib/screens/new_screen.dart`
2. Add route in `main.dart`:
```dart
'/route-name': (context) => const NewScreen(),
```

### Add New Provider
1. Create `lib/providers/new_provider.dart`
2. Register in `main.dart` MultiProvider

### Customize Colors
Edit `lib/constants/app_colors.dart`

---

## 🐛 Debugging

### Check Current State
```dart
debugPrint('User: ${authProvider.user}');
debugPrint('Cart items: ${cartProvider.itemCount}');
```

### Network Debugging
- All API calls via Dio
- Check interceptors in ApiService

### Widget Tree
```bash
flutter run --verbose
```

---

## 📱 Screen Reference

### Login Screen
- Path: `/login`
- Auto-route if not authenticated
- Form validation included

### Home Screen
- Path: `/home`
- Product grid with search
- Cart badge in AppBar

### Product Detail
- Path: `/product-detail`
- Argument: productId (int)
- Full product info with add to cart

### Cart Screen
- Path: `/cart`
- Quantity adjustments
- Checkout form

### Orders Screen
- Path: `/orders`
- Order history list
- Status indicators

### Order Detail
- Path: `/order-detail`
- Argument: orderId (int)
- Status tracking
- Cancel option

### Profile Screen
- Path: `/profile`
- Edit user info
- Logout button

---

## 🔌 API Response Format

### Success Response
```json
{
  "data": {...},
  "message": "Success"
}
```

### Error Response
```json
{
  "message": "Error description",
  "errors": {...}
}
```

### Pagination
```json
{
  "data": [...],
  "pagination": {
    "total": 100,
    "per_page": 10,
    "current_page": 1,
    "last_page": 10
  }
}
```

---

## ⚙️ Troubleshooting

| Issue | Solution |
|-------|----------|
| "API Connection Error" | Check backend is running & URL is correct |
| "Widget not rebuilding" | Use `context.watch()` instead of `context.read()` |
| "State persists after logout" | Check StorageService.clearAll() is called |
| "Build fails" | Run `flutter clean` then `flutter pub get` |

---

## 📦 Dependencies Quick Reference

| Package | Use Case |
|---------|----------|
| provider | State management |
| dio | HTTP requests |
| shared_preferences | Local storage |
| cached_network_image | Image caching |
| intl | Date/time formatting |

---

## 🎨 UI Components

All reusable widgets in `lib/widgets/common_widgets.dart`:

- `CustomButton` - Styled button with loading state
- `AppTextField` - Form input with validation
- `LoadingWidget` - Loading indicator
- `ErrorStateWidget` - Error display
- `EmptyStateWidget` - Empty state view

```dart
// Usage
AppButton(
  label: 'Click me',
  onPressed: () {},
  isLoading: false,
)
```

---

## 📊 State Management Pattern

```dart
// Reading state (rebuild on change)
context.watch<AuthProvider>().isLoggedIn

// Reading state (no rebuild)
context.read<AuthProvider>().login(email, password)

// Creating provider
Provider<ApiService>(create: (_) => ApiService())

// Notifying listeners
notifyListeners()
```

---

## 🔒 Security Notes

1. **Token Storage**: JWT stored in SharedPreferences
2. **API Headers**: Bearer token auto-added to requests
3. **Input Validation**: All forms validated before submission
4. **Error Messages**: Never expose sensitive data

---

## 🚀 Performance Tips

1. Use `const` keywords for static widgets
2. Implement pagination for long lists
3. Cache images with `cached_network_image`
4. Use `context.watch()` wisely (expensive rebuilds)
5. Implement proper error boundaries

---

## 📚 Resources

- Flutter Docs: https://flutter.dev
- Dart Docs: https://dart.dev
- Provider Package: https://pub.dev/packages/provider
- Dio HTTP: https://pub.dev/packages/dio

---

## 💡 Tips & Tricks

### Quick API Test
```dart
// In main or debug screen
final api = ApiService();
final response = await api.getProducts();
debugPrint(response.data);
```

### Debug Provider State
```dart
debugPrint('Auth: ${context.read<AuthProvider>().user}');
debugPrint('Cart: ${context.read<CartProvider>().totalPrice}');
```

### Format Currency
```dart
String price = '\$${value.toStringAsFixed(2)}';
```

---

## ✅ Pre-Deployment Checklist

- [ ] API URL correctly set
- [ ] All screens tested
- [ ] No debug prints in code
- [ ] Error messages user-friendly
- [ ] App icon & splash screen added
- [ ] Version number updated
- [ ] Privacy policy reviewed
- [ ] Terms of service agreed

---

**Quick Links:**
- Setup Guide: `SETUP_GUIDE.md`
- Project Summary: `PROJECT_SUMMARY.md`
- API Documentation: Check Laravel backend docs

---

Happy Coding! 🎉

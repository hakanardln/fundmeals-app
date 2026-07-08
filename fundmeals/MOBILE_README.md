# FundMeals Mobile App

A Flutter mobile application for FundMeals - a platform for ordering and managing food deliveries.

## Features

### Authentication
- User login and registration
- Secure token-based authentication
- Profile management
- Session persistence

### Product Management
- Browse available meals/products
- Search products by name or description
- Filter products by category
- View product details and ratings
- Real-time product availability status

### Shopping Cart
- Add/remove items from cart
- Update item quantities
- View cart totals
- Persistent cart state

### Order Management
- Create orders from cart
- View order history
- Track order status (pending, confirmed, preparing, ready, delivered)
- Cancel orders
- View detailed order information
- Delivery address management

### User Profile
- Update profile information
- View user details
- Manage delivery addresses
- Logout functionality

## Project Structure

```
lib/
├── constants/
│   ├── app_colors.dart       # Color palette
│   └── app_constants.dart    # API endpoints and configuration
├── models/
│   ├── user_model.dart       # User data model
│   ├── product_model.dart    # Product data model
│   └── order_model.dart      # Order and OrderItem models
├── services/
│   ├── api_service.dart      # HTTP API communication
│   └── storage_service.dart  # Local data persistence
├── providers/
│   ├── auth_provider.dart    # Authentication state management
│   ├── product_provider.dart # Product listing state management
│   ├── cart_provider.dart    # Shopping cart state management
│   └── order_provider.dart   # Order management state management
├── screens/
│   ├── login_screen.dart     # Login page
│   ├── register_screen.dart  # Registration page
│   ├── home_screen.dart      # Main product listing
│   ├── cart_screen.dart      # Shopping cart
│   ├── orders_screen.dart    # Order history
│   └── profile_screen.dart   # User profile
├── widgets/
│   └── common_widgets.dart   # Reusable widgets
└── main.dart                 # App entry point
```

## Dependencies

- **http**: ^1.1.0 - HTTP requests
- **dio**: ^5.3.1 - HTTP client with interceptors
- **provider**: ^6.0.0 - State management
- **shared_preferences**: ^2.2.2 - Local storage
- **go_router**: ^12.1.0 - Navigation and routing
- **cached_network_image**: ^3.3.0 - Image caching
- **intl**: ^0.19.0 - Internationalization
- **connectivity_plus**: ^5.0.0 - Network connectivity

## Getting Started

### Prerequisites
- Flutter SDK (3.11.1 or higher)
- Dart SDK
- Android Studio / Xcode for platform-specific setup

### Installation

1. Clone the repository
```bash
cd fundmeals
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## Configuration

### API Base URL
Update the API base URL in `lib/constants/app_constants.dart`:

```dart
static const String apiBaseUrl = 'http://127.0.0.1:8000/api';
```

Change this to your Laravel backend URL.

## Build

### Android
```bash
flutter build apk
# or
flutter build app-bundle
```

### iOS
```bash
flutter build ios
```

## API Integration

The app connects to a Laravel backend. Ensure your Laravel API provides the following endpoints:

- `POST /api/auth/login`
- `POST /api/auth/register`
- `POST /api/auth/logout`
- `GET /api/user/profile`
- `PUT /api/user/profile`
- `GET /api/products`
- `GET /api/products/{id}`
- `GET /api/orders`
- `POST /api/orders`
- `GET /api/orders/{id}`
- `POST /api/orders/{id}/cancel`
- `GET /api/orders/{id}/tracking`

## State Management

The app uses the Provider package for state management:

- **AuthProvider**: Manages authentication state and user data
- **ProductProvider**: Manages product listing and search
- **CartProvider**: Manages shopping cart items
- **OrderProvider**: Manages user orders

## Storage

Local data is stored using SharedPreferences for:
- Authentication tokens
- User data
- Login state

## Error Handling

The app includes comprehensive error handling:
- Network error messages
- API error responses
- Validation errors
- Timeout handling

## Testing

The app includes error boundaries and loading states for better UX.

## License

This project is proprietary and confidential.

## Support

For issues or questions, contact the development team.

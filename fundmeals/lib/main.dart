import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/store_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/theme_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/order_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<ApiService>(create: (_) => ApiService()),
        
        // Providers
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) => AuthProvider(context.read<ApiService>()),
          update: (context, apiService, authProvider) {
            return authProvider ?? AuthProvider(apiService);
          },
        ),
        ChangeNotifierProxyProvider<ApiService, ProductProvider>(
          create: (context) => ProductProvider(context.read<ApiService>()),
          update: (context, apiService, productProvider) {
            return productProvider ?? ProductProvider(apiService);
          },
        ),
        ChangeNotifierProxyProvider<ApiService, StoreProvider>(
          create: (context) => StoreProvider(context.read<ApiService>()),
          update: (context, apiService, storeProvider) {
            return storeProvider ?? StoreProvider(apiService);
          },
        ),
        ChangeNotifierProxyProvider<ApiService, OrderProvider>(
          create: (context) => OrderProvider(context.read<ApiService>()),
          update: (context, apiService, orderProvider) {
            return orderProvider ?? OrderProvider(apiService);
          },
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              fontFamily: 'Roboto',
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
            home: const SplashScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/main': (context) => const MainScreen(),
              '/home': (context) => const HomeScreen(),
              '/cart': (context) => const CartScreen(),
              '/orders': (context) => const OrdersScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/product-detail': (context) {
                final productId = ModalRoute.of(context)?.settings.arguments as int;
                return ProductDetailScreen(productId: productId);
              },
              '/order-detail': (context) {
                final orderId = ModalRoute.of(context)?.settings.arguments as int;
                return OrderDetailScreen(orderId: orderId);
              },
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'core/routing/product_deep_link.dart';
import 'features/details/screens/product_details_screen.dart';
import 'features/home/di/home_dependencies.dart';
import 'features/home/domain/use_cases/load_product.dart';
import 'features/splash/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      onGenerateInitialRoutes: (initialRoute) {
        final productId = ProductDeepLink.productIdFromRoute(initialRoute);
        if (productId != null) {
          return [_productDetailsRoute(initialRoute, productId)];
        }
        return [
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/'),
            builder: (_) => const SplashScreen(),
          ),
        ];
      },
      onGenerateRoute: (settings) {
        final productId = ProductDeepLink.productIdFromRoute(settings.name);
        if (productId == null) return null;
        return _productDetailsRoute(settings.name!, productId);
      },
    );
  }

  MaterialPageRoute<void> _productDetailsRoute(String route, String productId) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: route),
      builder: (_) => ProductDetailsScreen.fromId(
        productId: productId,
        loadProduct: LoadProduct(homeRepository),
      ),
    );
  }
}

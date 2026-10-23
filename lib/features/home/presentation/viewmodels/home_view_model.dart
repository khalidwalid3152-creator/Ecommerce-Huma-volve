import 'package:flutter/material.dart';

import '../../../../core/dummy_data.dart';
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/errors/home_failure.dart';
import '../../domain/use_cases/load_home.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this._loadHome});

  final LoadHome _loadHome;

  List<Product> products = [];
  List<HomeCategory> categories = [];
  String selectedCategory = 'all';
  String searchQuery = '';
  String? errorMessage;
  bool isLoading = false;

  List<Product> get visibleProducts {
    final query = searchQuery.trim().toLowerCase();
    return products
        .where((product) {
          final matchesCategory =
              selectedCategory == 'all' ||
              product.categorySlug == selectedCategory;
          final matchesQuery =
              query.isEmpty ||
              product.name.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query);
          return matchesCategory && matchesQuery;
        })
        .toList(growable: false);
  }

  Future<void> load() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final homeData = await _loadHome();
      products = homeData.products.map(_toUiProduct).toList(growable: false);
      categories = homeData.categories;
    } on HomeFailure catch (failure) {
      errorMessage = failure.message;
    } catch (_) {
      errorMessage = 'Products could not be loaded. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String slug) {
    selectedCategory = slug;
    notifyListeners();
  }

  void updateSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  Product _toUiProduct(HomeProduct product) {
    final category = product.categorySlug.toLowerCase();
    final sizes =
        category.contains('clothing') ||
            category.contains('shirt') ||
            category.contains('dress')
        ? ['S', 'M', 'L', 'XL']
        : ['One Size'];

    return Product(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      colors: const [Colors.black, Colors.white, Colors.grey],
      sizes: sizes,
      categorySlug: product.categorySlug,
    );
  }
}

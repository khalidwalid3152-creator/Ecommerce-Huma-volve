import 'package:flutter/material.dart';

import '../../../../core/dummy_data.dart';
import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_product.dart';
import '../../domain/errors/home_failure.dart';
import '../../domain/use_cases/load_home.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.loadHome});

  final LoadHome loadHome;
  static const int pageSize = 20;

  List<Product> products = [];
  List<HomeCategory> categories = [];
  String selectedCategory = 'all';
  String searchQuery = '';
  String? errorMessage;
  String? loadMoreError;
  bool isLoading = false;
  bool isLoadingMore = false;
  int _totalProducts = 0;
  int _loadGeneration = 0;

  bool get hasMore => products.length < _totalProducts;

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
    final generation = ++_loadGeneration;
    isLoading = true;
    errorMessage = null;
    loadMoreError = null;
    isLoadingMore = false;
    products = [];
    categories = [];
    _totalProducts = 0;
    notifyListeners();

    try {
      final homeData = await loadHome(skip: 0, limit: pageSize);
      if (generation != _loadGeneration) return;
      products = homeData.products.map(_toUiProduct).toList(growable: false);
      categories = homeData.categories;
      _totalProducts = homeData.total;
    } on HomeFailure catch (failure) {
      if (generation != _loadGeneration) return;
      errorMessage = failure.message;
    } catch (_) {
      if (generation != _loadGeneration) return;
      errorMessage = 'Products could not be loaded. Please try again.';
    } finally {
      if (generation == _loadGeneration) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    final generation = _loadGeneration;
    isLoadingMore = true;
    loadMoreError = null;
    notifyListeners();

    try {
      final homeData = await loadHome(skip: products.length, limit: pageSize);
      if (generation != _loadGeneration) return;
      products = [...products, ...homeData.products.map(_toUiProduct)];
      if (homeData.categories.isNotEmpty) {
        categories = homeData.categories;
      }
      _totalProducts = homeData.total;
    } on HomeFailure catch (failure) {
      if (generation != _loadGeneration) return;
      loadMoreError = failure.message;
    } catch (_) {
      if (generation != _loadGeneration) return;
      loadMoreError = 'More products could not be loaded. Please try again.';
    } finally {
      if (generation == _loadGeneration) {
        isLoadingMore = false;
        notifyListeners();
      }
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

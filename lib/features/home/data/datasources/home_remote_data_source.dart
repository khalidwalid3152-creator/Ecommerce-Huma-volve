import 'package:dio/dio.dart';

import '../../domain/entities/home_category.dart';
import '../../domain/entities/home_data.dart';
import '../../domain/entities/home_product.dart';

class HomeRemoteDataSource {
  HomeRemoteDataSource({Dio? dio})
    : _dio = dio ?? Dio(BaseOptions(baseUrl: 'https://dummyjson.com'));

  final Dio _dio;

  Future<HomeData> loadHome({required int skip, required int limit}) async {
    final productResponse = await _dio.get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'limit': limit, 'skip': skip},
    );
    final categoryResponse = skip == 0
        ? await _dio.get<List<dynamic>>('/products/category-list')
        : null;

    final productData = productResponse.data?['products'];
    final totalData = productResponse.data?['total'];
    final categoryData = categoryResponse?.data;
    if (productData is! List ||
        totalData is! num ||
        (skip == 0 && categoryData == null)) {
      throw const FormatException('The product service returned invalid data.');
    }

    return HomeData(
      products: productData
          .whereType<Map<String, dynamic>>()
          .map(_productFromJson)
          .toList(growable: false),
      categories:
          categoryData
              ?.whereType<String>()
              .map(
                (slug) => HomeCategory(slug: slug, name: _categoryName(slug)),
              )
              .toList(growable: false) ??
          const [],
      total: totalData.toInt(),
    );
  }

  HomeProduct _productFromJson(Map<String, dynamic> json) {
    final images = json['images'];
    final imageUrl =
        json['thumbnail'] as String? ??
        (images is List && images.isNotEmpty
            ? images.first as String?
            : null) ??
        '';
    final categorySlug = json['category'] is Map<String, dynamic>
        ? (json['category'] as Map<String, dynamic>)['slug'] as String? ?? ''
        : json['category'] as String? ?? '';

    return HomeProduct(
      id: '${json['id'] ?? ''}',
      name: json['title'] as String? ?? 'Product',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: imageUrl,
      categorySlug: categorySlug,
    );
  }

  String _categoryName(String slug) {
    return slug
        .split('-')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }
}

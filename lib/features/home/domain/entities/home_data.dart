import 'home_category.dart';
import 'home_product.dart';

class HomeData {
  const HomeData({
    required this.products,
    required this.categories,
    required this.total,
  });

  final List<HomeProduct> products;
  final List<HomeCategory> categories;
  final int total;
}

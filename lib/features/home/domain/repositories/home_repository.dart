import '../entities/home_data.dart';
import '../entities/home_product.dart';

abstract interface class HomeRepository {
  Future<HomeData> loadHome({required int skip, required int limit});

  Future<HomeProduct> loadProduct(String id);
}

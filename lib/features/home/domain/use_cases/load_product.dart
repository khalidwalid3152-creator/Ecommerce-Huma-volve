import '../entities/home_product.dart';
import '../repositories/home_repository.dart';

class LoadProduct {
  const LoadProduct(this._repository);

  final HomeRepository _repository;

  Future<HomeProduct> call(String id) => _repository.loadProduct(id);
}

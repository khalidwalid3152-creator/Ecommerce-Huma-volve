import '../entities/home_data.dart';
import '../repositories/home_repository.dart';

class LoadHome {
  const LoadHome(this._repository);

  final HomeRepository _repository;

  Future<HomeData> call({required int skip, required int limit}) {
    return _repository.loadHome(skip: skip, limit: limit);
  }
}

import '../entities/home_data.dart';

abstract interface class HomeRepository {
  Future<HomeData> loadHome({required int skip, required int limit});
}

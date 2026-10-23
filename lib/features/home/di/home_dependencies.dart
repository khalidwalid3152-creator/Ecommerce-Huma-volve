import '../data/datasources/home_remote_data_source.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/use_cases/load_home.dart';
import '../presentation/viewmodels/home_view_model.dart';

final HomeRepository homeRepository = HomeRepositoryImpl(
  HomeRemoteDataSource(),
);

HomeViewModel createHomeViewModel() {
  return HomeViewModel(loadHome: LoadHome(homeRepository));
}

import 'package:dio/dio.dart';

import '../../domain/entities/home_data.dart';
import '../../domain/errors/home_failure.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._remoteDataSource);

  final HomeRemoteDataSource _remoteDataSource;

  @override
  Future<HomeData> loadHome() async {
    try {
      return await _remoteDataSource.loadHome();
    } on DioException catch (error) {
      throw HomeFailure(
        error.response == null
            ? 'Unable to connect. Check your internet connection and try again.'
            : 'Products could not be loaded. Please try again.',
      );
    } on FormatException catch (error) {
      throw HomeFailure(error.message);
    }
  }
}

import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_category.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_data.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/home_product.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/use_cases/load_home.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/viewmodels/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads pages and stops when all products are loaded', () async {
    final repository = _PagedHomeRepository();
    final viewModel = HomeViewModel(loadHome: LoadHome(repository));
    addTearDown(viewModel.dispose);

    await viewModel.load();

    expect(viewModel.products, hasLength(HomeViewModel.pageSize));
    expect(viewModel.hasMore, isTrue);
    expect(repository.requests, [(0, HomeViewModel.pageSize)]);

    await viewModel.loadMore();

    expect(viewModel.products, hasLength(HomeViewModel.pageSize + 1));
    expect(viewModel.hasMore, isFalse);
    expect(repository.requests, [
      (0, HomeViewModel.pageSize),
      (HomeViewModel.pageSize, HomeViewModel.pageSize),
    ]);

    await viewModel.loadMore();
    expect(repository.requests, hasLength(2));
  });
}

class _PagedHomeRepository implements HomeRepository {
  final List<(int, int)> requests = [];

  @override
  Future<HomeProduct> loadProduct(String id) async {
    return HomeProduct(
      id: id,
      name: 'Product $id',
      description: '',
      price: 10,
      imageUrl: '',
      categorySlug: 'test',
    );
  }

  @override
  Future<HomeData> loadHome({required int skip, required int limit}) async {
    requests.add((skip, limit));
    final count = skip == 0 ? limit : 1;

    return HomeData(
      products: List.generate(
        count,
        (index) => HomeProduct(
          id: '${skip + index}',
          name: 'Product ${skip + index}',
          description: '',
          price: 10,
          imageUrl: '',
          categorySlug: 'test',
        ),
      ),
      categories: skip == 0
          ? const [HomeCategory(slug: 'test', name: 'Test')]
          : const [],
      total: HomeViewModel.pageSize + 1,
    );
  }
}

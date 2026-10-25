import 'package:flutter/material.dart';

import '../../../core/dummy_data.dart';
import '../../../core/theme.dart';
import '../di/home_dependencies.dart';
import '../domain/entities/home_category.dart';
import '../presentation/viewmodels/home_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel = createHomeViewModel()..load();
    _scrollController.addListener(_loadMoreWhenNearEnd);
  }

  void _loadMoreWhenNearEnd() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 300) {
      _viewModel.loadMore();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    _searchController.dispose();
    _scrollController
      ..removeListener(_loadMoreWhenNearEnd)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) => RefreshIndicator(
            onRefresh: _viewModel.load,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.menu,
                                color: AppTheme.primary,
                              ),
                            ),
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                dummyUser.profilePictureUrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Explore',
                          style: Theme.of(context).textTheme.displayLarge
                              ?.copyWith(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Best trendy collection!',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _viewModel.updateSearch,
                            decoration: InputDecoration(
                              hintText: 'Search clothes...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _viewModel.categories.length + 1,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final category = index == 0
                                  ? const HomeCategory(slug: 'all', name: 'All')
                                  : _viewModel.categories[index - 1];
                              return CategoryChip(
                                label: category.name,
                                isSelected:
                                    _viewModel.selectedCategory ==
                                    category.slug,
                                onTap: () =>
                                    _viewModel.selectCategory(category.slug),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_viewModel.isLoading && _viewModel.products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_viewModel.errorMessage != null &&
                    _viewModel.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _viewModel.load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_viewModel.visibleProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No products found.'),
                          if (_viewModel.isLoadingMore)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            )
                          else if (_viewModel.hasMore)
                            TextButton(
                              onPressed: _viewModel.loadMore,
                              child: Text(
                                _viewModel.loadMoreError == null
                                    ? 'Load more products'
                                    : 'Retry loading products',
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return ProductCard(
                          product: _viewModel.visibleProducts[index],
                        );
                      }, childCount: _viewModel.visibleProducts.length),
                    ),
                  ),
                if (_viewModel.products.isNotEmpty &&
                    (_viewModel.isLoadingMore ||
                        _viewModel.loadMoreError != null ||
                        _viewModel.hasMore))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: _viewModel.isLoadingMore
                            ? const CircularProgressIndicator()
                            : _viewModel.loadMoreError != null
                            ? TextButton.icon(
                                onPressed: _viewModel.loadMore,
                                icon: const Icon(Icons.refresh),
                                label: const Text(
                                  'Could not load more. Tap to retry.',
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

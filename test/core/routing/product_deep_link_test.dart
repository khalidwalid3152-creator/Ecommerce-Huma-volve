import 'package:ecommerce_app_huma_volve/core/routing/product_deep_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates product deep links', () {
    expect(ProductDeepLink.forProduct('42'), 'humavolve://app/products/42');
  });

  test('parses custom scheme and app route product links', () {
    expect(
      ProductDeepLink.productIdFromRoute('humavolve://app/products/42'),
      '42',
    );
    expect(ProductDeepLink.productIdFromRoute('humavolve://products/42'), '42');
    expect(ProductDeepLink.productIdFromRoute('/products/42'), '42');
  });

  test('rejects invalid product routes', () {
    expect(ProductDeepLink.productIdFromRoute('/products/0'), isNull);
    expect(
      ProductDeepLink.productIdFromRoute('/products/not-a-number'),
      isNull,
    );
    expect(ProductDeepLink.productIdFromRoute('/cart'), isNull);
  });
}

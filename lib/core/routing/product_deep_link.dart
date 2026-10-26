class ProductDeepLink {
  const ProductDeepLink._();

  static const scheme = 'humavolve';

  static String forProduct(String id) => '$scheme://app/products/$id';

  static String? productIdFromRoute(String? route) {
    if (route == null || route.isEmpty) return null;

    final uri = Uri.tryParse(route);
    if (uri == null) return null;

    final segments = uri.pathSegments;
    final id = uri.scheme == scheme && uri.host == 'products'
        ? (segments.length == 1 ? segments.single : null)
        : (segments.length == 2 && segments.first == 'products'
              ? segments.last
              : null);
    final numericId = int.tryParse(id ?? '');
    return numericId != null && numericId > 0 ? id : null;
  }
}

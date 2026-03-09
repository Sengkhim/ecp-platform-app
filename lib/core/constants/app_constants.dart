class AppConstants {
  AppConstants._();

  // ── API ────────────────────────────────────────────────────────────────────
  static const String baseUrl = 'http://api-gateway.ecp-dev.svc.cluster.local';

  static const String orderEndpoint = '/api/order';
  static const String productGraphql = '/api/product/graphql/';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ── Routes ─────────────────────────────────────────────────────────────────
  static const String routeHome = '/';
  static const String routeOrders = '/orders';
  static const String routeOrderDetail = '/orders/detail';
  static const String routeCreateOrder = '/orders/create';
  static const String routeProducts = '/products';
}

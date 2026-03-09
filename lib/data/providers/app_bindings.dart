// lib/data/providers/app_bindings.dart

import 'package:get/get.dart';
import '../../core/network/api_client.dart';
import '../repositories/order_repository.dart';
import '../../modules/orders/controllers/order_list_controller.dart';
import '../../modules/orders/controllers/create_order_controller.dart';

// ── Initial bindings (app startup) ────────────────────────────────────────────

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<OrderRepository>(OrderRepository(), permanent: true);
  }
}

// ── Order list binding ────────────────────────────────────────────────────────

class OrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderListController>(() => OrderListController());
  }
}

// ── Create order binding ──────────────────────────────────────────────────────

class CreateOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateOrderController>(() => CreateOrderController());
  }
}

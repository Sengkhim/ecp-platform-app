// lib/modules/orders/controllers/order_list_controller.dart

import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/constants/app_constants.dart';

class OrderListController extends GetxController {
  final OrderRepository _repo = Get.find();

  // ── State ─────────────────────────────────────────────────────────────────
  final RxList<Order> orders = <Order>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;
  final Rx<OrderStatus?> statusFilter = Rx<OrderStatus?>(null);

  // ── Computed ──────────────────────────────────────────────────────────────

  List<Order> get filtered {
    var list = orders.toList();

    final status = statusFilter.value;
    if (status != null) {
      list = list.where((o) => o.status == status).toList();
    }

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where(
            (o) =>
                o.orderNumber.toLowerCase().contains(q) ||
                o.customerName.toLowerCase().contains(q) ||
                o.customerEmail.toLowerCase().contains(q),
          )
          .toList();
    }

    return list;
  }

  int get totalOrders => orders.length;
  int get pendingOrders =>
      orders.where((o) => o.status == OrderStatus.pending).length;
  int get activeOrders => orders
      .where(
        (o) =>
            o.status == OrderStatus.confirmed ||
            o.status == OrderStatus.processing ||
            o.status == OrderStatus.shipped,
      )
      .length;
  double get totalRevenue => orders
      .where((o) => o.status != OrderStatus.cancelled)
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  // ── Methods ───────────────────────────────────────────────────────────────

  Future<void> fetchOrders({bool silent = false}) async {
    if (!silent)
      isLoading.value = true;
    else
      isRefreshing.value = true;
    error.value = '';
    try {
      final data = await _repo.getOrders();
      orders.assignAll(data);
    } catch (e) {
      error.value = e.toString().replaceFirst('ApiException: ', '');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refresh() => fetchOrders(silent: true);

  void setSearch(String q) => searchQuery.value = q;
  void setStatusFilter(OrderStatus? s) => statusFilter.value = s;
  void clearFilters() {
    searchQuery.value = '';
    statusFilter.value = null;
  }

  Future<void> cancelOrder(String id, String reason) async {
    try {
      final updated = await _repo.cancelOrder(id, reason);
      final idx = orders.indexWhere((o) => o.id == id);
      if (idx != -1) orders[idx] = updated;
      showSuccess('Order cancelled');
    } catch (e) {
      showError(e.toString().replaceFirst('ApiException: ', ''));
    }
  }

  Future<void> deleteOrder(String id) async {
    try {
      await _repo.deleteOrder(id);
      orders.removeWhere((o) => o.id == id);
      showSuccess('Order deleted');
    } catch (e) {
      showError(e.toString().replaceFirst('ApiException: ', ''));
    }
  }

  void goToDetail(Order order) {
    Get.toNamed(AppConstants.routeOrderDetail, arguments: order);
  }

  void goToCreate() {
    Get.toNamed(AppConstants.routeCreateOrder);
  }
}

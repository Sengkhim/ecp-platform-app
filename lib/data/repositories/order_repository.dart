// lib/data/repositories/order_repository.dart

import 'package:get/get.dart';
import '../models/order_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';

class OrderRepository extends GetxService {
  final ApiClient _client = Get.find();

  // ── Fetch all orders ──────────────────────────────────────────────────────

  Future<List<Order>> getOrders() async {
    final data = await _client.get<List<dynamic>>(
      AppConstants.orderEndpoint,
    );
    return data.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Fetch single order ────────────────────────────────────────────────────

  Future<Order> getOrderById(String id) async {
    final data = await _client.get<Map<String, dynamic>>(
      '${AppConstants.orderEndpoint}/$id',
    );
    return Order.fromJson(data);
  }

  // ── Create order ──────────────────────────────────────────────────────────

  Future<Order> createOrder(CreateOrderInput input) async {
    final data = await _client.post<Map<String, dynamic>>(
      AppConstants.orderEndpoint,
      data: input.toJson(),
    );
    return Order.fromJson(data);
  }

  // ── Cancel order ──────────────────────────────────────────────────────────

  Future<Order> cancelOrder(String id, String reason) async {
    final data = await _client.post<Map<String, dynamic>>(
      '${AppConstants.orderEndpoint}/$id/cancel',
      data: {'reason': reason},
    );
    return Order.fromJson(data);
  }

  // ── Delete order ──────────────────────────────────────────────────────────

  Future<void> deleteOrder(String id) async {
    await _client.delete('${AppConstants.orderEndpoint}/$id');
  }
}

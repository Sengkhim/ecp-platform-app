// lib/modules/orders/views/order_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/order_list_controller.dart';
import '../widgets/order_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/order_model.dart';

class OrderListView extends GetView<OrderListController> {
  const OrderListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          Obx(
            () => controller.isRefreshing.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: controller.refresh,
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToCreate,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.bg,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Order',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _StatsBar(controller: controller),
          _SearchBar(controller: controller),
          _StatusFilters(controller: controller),
          Expanded(child: _OrderList(controller: controller)),
        ],
      ),
    );
  }
}

// ── Stats bar ─────────────────────────────────────────────────────────────────

class _StatsBar extends StatelessWidget {
  final OrderListController controller;
  const _StatsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Expanded(
                  child: StatCard(
                label: 'Total',
                value: controller.totalOrders.toString(),
                color: AppColors.textPrimary,
                icon: Icons.receipt_long_outlined,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: StatCard(
                label: 'Pending',
                value: controller.pendingOrders.toString(),
                color: AppColors.statusPending,
                icon: Icons.pending_outlined,
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: StatCard(
                label: 'Active',
                value: controller.activeOrders.toString(),
                color: AppColors.statusShipped,
                icon: Icons.local_shipping_outlined,
              )),
            ],
          ),
        ));
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final OrderListController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: TextField(
        onChanged: controller.setSearch,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search order #, name, email…',
          prefixIcon: const Icon(Icons.search_rounded,
              size: 18, color: AppColors.textMuted),
          suffixIcon: Obx(
            () => controller.searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      controller.setSearch('');
                    },
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.textMuted),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

// ── Status filters ────────────────────────────────────────────────────────────

class _StatusFilters extends StatelessWidget {
  final OrderListController controller;
  const _StatusFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Obx(() {
        final current = controller.statusFilter.value;
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          scrollDirection: Axis.horizontal,
          children: [
            _FilterChip(
              label: 'All',
              selected: current == null,
              color: AppColors.primary,
              onTap: () => controller.setStatusFilter(null),
            ),
            const SizedBox(width: 6),
            ...OrderStatus.values.map((s) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _FilterChip(
                    label: s.label,
                    selected: current == s,
                    color: _statusColor(s),
                    onTap: () => controller.setStatusFilter(s),
                  ),
                )),
          ],
        );
      }),
    );
  }

  Color _statusColor(OrderStatus s) => switch (s) {
        OrderStatus.pending => AppColors.statusPending,
        OrderStatus.confirmed => AppColors.statusConfirmed,
        OrderStatus.processing => AppColors.statusProcessing,
        OrderStatus.shipped => AppColors.statusShipped,
        OrderStatus.delivered => AppColors.statusDelivered,
        OrderStatus.cancelled => AppColors.statusCancelled,
        OrderStatus.refunded => AppColors.statusRefunded,
      };
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color.withOpacity(0.4) : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Order list body ───────────────────────────────────────────────────────────

class _OrderList extends StatelessWidget {
  final OrderListController controller;
  const _OrderList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, __) => const OrderCardShimmer(),
        );
      }

      if (controller.error.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(controller.error.value,
                  style: const TextStyle(color: AppColors.textMuted),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: controller.fetchOrders,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      final list = controller.filtered;

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 52, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text('No orders found',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(
                controller.searchQuery.isNotEmpty ||
                        controller.statusFilter.value != null
                    ? 'Try adjusting your filters'
                    : 'Create your first order',
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              if (controller.searchQuery.isNotEmpty ||
                  controller.statusFilter.value != null) ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Clear filters'),
                ),
              ],
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: list.length,
          itemBuilder: (_, i) => OrderCard(
            order: list[i],
            onTap: () => controller.goToDetail(list[i]),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: i * 30),
                duration: const Duration(milliseconds: 250),
              )
              .slideY(begin: 0.04, end: 0),
        ),
      );
    });
  }
}

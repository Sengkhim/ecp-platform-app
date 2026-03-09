// lib/modules/orders/views/order_detail_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../widgets/order_widgets.dart';
import '../controllers/order_list_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/order_model.dart';

class OrderDetailView extends StatelessWidget {
  const OrderDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final Order order = Get.arguments as Order;
    final ctrl = Get.find<OrderListController>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(order.orderNumber,
            style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 15,
                color: AppColors.primary)),
        actions: [
          if (order.isCancellable)
            TextButton.icon(
              onPressed: () => _showCancelDialog(context, order, ctrl),
              icon: const Icon(Icons.cancel_outlined,
                  size: 16, color: AppColors.error),
              label: const Text('Cancel',
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status + amounts ─────────────────────────────────────────────
            _AmountCard(order: order)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 16),

            // ── Customer ─────────────────────────────────────────────────────
            _Section(
              title: 'Customer',
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  DetailRow(label: 'Name', value: order.customerName),
                  DetailRow(label: 'Email', value: order.customerEmail),
                  DetailRow(
                      label: 'Customer ID',
                      value: order.customerId,
                      monospace: true),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 60.ms, duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 12),

            // ── Financial ────────────────────────────────────────────────────
            _Section(
              title: 'Financials',
              icon: Icons.attach_money_rounded,
              child: Column(
                children: [
                  DetailRow(
                      label: 'Subtotal', value: formatCurrency(order.subTotal)),
                  DetailRow(
                      label: 'Tax', value: formatCurrency(order.taxAmount)),
                  DetailRow(
                      label: 'Shipping',
                      value: formatCurrency(order.shippingCost)),
                  const Divider(height: 16),
                  DetailRow(
                    label: 'Total',
                    value: formatCurrency(order.totalAmount),
                    valueColor: AppColors.primary,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 120.ms, duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 12),

            // ── Items ─────────────────────────────────────────────────────────
            _Section(
              title: 'Items (${order.items.length})',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children:
                    order.items.map((item) => _ItemRow(item: item)).toList(),
              ),
            )
                .animate()
                .fadeIn(delay: 180.ms, duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            const SizedBox(height: 12),

            // ── Timestamps ────────────────────────────────────────────────────
            _Section(
              title: 'Timeline',
              icon: Icons.access_time_rounded,
              child: Column(
                children: [
                  DetailRow(
                      label: 'Created', value: formatDateTime(order.createdAt)),
                  if (order.updatedAt != null)
                    DetailRow(
                        label: 'Updated',
                        value: formatDateTime(order.updatedAt)),
                  if (order.completedAt != null)
                    DetailRow(
                        label: 'Completed',
                        value: formatDateTime(order.completedAt)),
                  if (order.cancelledAt != null)
                    DetailRow(
                        label: 'Cancelled',
                        value: formatDateTime(order.cancelledAt),
                        valueColor: AppColors.error),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 240.ms, duration: 300.ms)
                .slideY(begin: 0.05, end: 0),

            // ── Cancellation reason ───────────────────────────────────────────
            if (order.cancellationReason != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.error),
                        SizedBox(width: 6),
                        Text('Cancellation Reason',
                            style: TextStyle(
                                color: AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(order.cancellationReason!,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 300.ms),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
      BuildContext context, Order order, OrderListController ctrl) {
    final reasonCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ${order.orderNumber}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontFamily: 'monospace',
                    fontSize: 13)),
            const SizedBox(height: 14),
            const Text('Reason *',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                  hintText: 'e.g. Customer requested cancellation'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Keep',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final r = reasonCtrl.text.trim();
              if (r.isEmpty) return;
              Get.back();
              ctrl.cancelOrder(order.id, r);
              Get.back(); // pop detail
            },
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}

// ── Amount card ───────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  final Order order;
  const _AmountCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OrderStatusChip(status: order.status),
              const Spacer(),
              Text(
                formatCurrency(order.totalAmount),
                style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerName,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          Text(order.orderNumber,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontFamily: 'monospace')),
        ],
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(title.toUpperCase(),
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Item row ──────────────────────────────────────────────────────────────────

class _ItemRow extends StatelessWidget {
  final OrderItem item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.surface3,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    size: 16, color: AppColors.textMuted),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    Text('SKU: ${item.sku}',
                        style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),
              Text(formatCurrency(item.totalPrice),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Mini(label: 'Qty', value: item.quantity.toString()),
              const SizedBox(width: 8),
              _Mini(label: 'Unit', value: formatCurrency(item.unitPrice)),
              const SizedBox(width: 8),
              _Mini(
                label: 'Discount',
                value: item.discount > 0
                    ? '-${formatCurrency(item.discount)}'
                    : '—',
                valueColor: item.discount > 0 ? AppColors.success : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _Mini({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface3,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace'),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// lib/modules/orders/views/create_order_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_order_controller.dart';
import '../widgets/order_widgets.dart';
import '../../../core/theme/app_theme.dart';

class CreateOrderView extends GetView<CreateOrderController> {
  const CreateOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('New Order'),
        actions: [
          Obx(
            () => controller.isSubmitting.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                  )
                : TextButton.icon(
                    onPressed: controller.submit,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Create'),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Customer ────────────────────────────────────────────────────
              const SectionHeader('Customer Information'),
              AppField(
                label: 'Customer ID',
                ctrl: controller.customerIdCtrl,
                hint: '3fa85f64-...',
                required: true,
              ),
              const SizedBox(height: 12),
              AppField(
                label: 'Customer Name',
                ctrl: controller.customerNameCtrl,
                hint: 'Kimheang',
                required: true,
              ),
              const SizedBox(height: 12),
              AppField(
                label: 'Email',
                ctrl: controller.customerEmailCtrl,
                hint: 'user@example.com',
                required: true,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email is required';
                  if (!GetUtils.isEmail(v.trim())) return 'Enter a valid email';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ── Order settings ──────────────────────────────────────────────
              const SectionHeader('Order Settings'),
              Row(
                children: [
                  Expanded(
                      child: _DropdownField(
                    label: 'Currency',
                    value: controller.currency,
                    options: controller.currencies,
                  )),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _DropdownField(
                    label: 'Payment Method',
                    value: controller.paymentMethod,
                    options: controller.paymentMethods,
                  )),
                ],
              ),
              const SizedBox(height: 12),
              AppField(
                label: 'Notes',
                ctrl: controller.notesCtrl,
                hint: 'Optional order notes',
                maxLines: 2,
              ),

              const SizedBox(height: 20),

              // ── Items ────────────────────────────────────────────────────────
              Row(
                children: [
                  const SectionHeader('Items'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: controller.addItem,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label:
                        const Text('Add Item', style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary),
                  ),
                ],
              ),

              Obx(() => Column(
                    children: [
                      ...controller.items.asMap().entries.map(
                            (e) => _ItemForm(
                              index: e.key,
                              ctrl: controller,
                              canRemove: controller.items.length > 1,
                            ),
                          ),
                    ],
                  )),

              // ── Subtotal preview ─────────────────────────────────────────────
              Obx(() => Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimated Subtotal',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 13)),
                        Text(
                          '\$${controller.subtotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 32),

              // ── Submit button ────────────────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submit,
                      icon: const Icon(Icons.receipt_long_rounded, size: 18),
                      label: Text(controller.isSubmitting.value
                          ? 'Creating…'
                          : 'Create Order'),
                    ),
                  )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Item form row ─────────────────────────────────────────────────────────────

class _ItemForm extends StatelessWidget {
  final int index;
  final CreateOrderController ctrl;
  final bool canRemove;
  const _ItemForm({
    required this.index,
    required this.ctrl,
    required this.canRemove,
  });

  @override
  Widget build(BuildContext context) {
    final item = ctrl.items[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Item ${index + 1}',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: () => ctrl.removeItem(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.remove_rounded,
                        size: 14, color: AppColors.error),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          AppField(
              label: 'Product ID',
              ctrl: item.productIdCtrl,
              hint: '3fa85f64-...',
              required: true),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: AppField(
                      label: 'Product Name',
                      ctrl: item.productNameCtrl,
                      hint: 'iPhone 15 Pro',
                      required: true)),
              const SizedBox(width: 10),
              Expanded(
                  child: AppField(
                      label: 'SKU',
                      ctrl: item.skuCtrl,
                      hint: 'SKU-001',
                      required: true)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: AppField(
                label: 'Qty',
                ctrl: item.quantityCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Min 1';
                  return null;
                },
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: AppField(
                label: 'Unit Price',
                ctrl: item.unitPriceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n < 0) return 'Invalid';
                  return null;
                },
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: AppField(
                label: 'Discount',
                ctrl: item.discountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              )),
            ],
          ),
          const SizedBox(height: 10),
          AppField(
              label: 'Notes',
              ctrl: item.notesCtrl,
              hint: 'Optional item notes'),
        ],
      ),
    );
  }
}

// ── Dropdown field ────────────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final RxString value;
  final List<String> options;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Obx(() => DropdownButtonFormField<String>(
              value: value.value,
              dropdownColor: AppColors.surface2,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: const InputDecoration(),
              items: options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) value.value = v;
              },
            )),
      ],
    );
  }
}

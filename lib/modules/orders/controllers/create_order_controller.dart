// lib/modules/orders/controllers/create_order_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../core/utils/app_utils.dart';

class CreateOrderController extends GetxController {
  final OrderRepository _repo = Get.find();

  // ── Form keys ─────────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();

  // ── Customer fields ───────────────────────────────────────────────────────
  final customerIdCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final customerEmailCtrl = TextEditingController();
  final notesCtrl = TextEditingController();

  // ── Order fields ──────────────────────────────────────────────────────────
  final RxString currency = 'USD'.obs;
  final RxString paymentMethod = 'ABA'.obs;

  // ── Items ─────────────────────────────────────────────────────────────────
  final RxList<_ItemDraft> items = <_ItemDraft>[].obs;

  // ── State ─────────────────────────────────────────────────────────────────
  final RxBool isSubmitting = false.obs;

  final List<String> currencies = ['USD', 'KHR', 'THB', 'EUR'];
  final List<String> paymentMethods = ['ABA', 'ACLEDA', 'Wing', 'Cash', 'Card'];

  // ── Computed ──────────────────────────────────────────────────────────────

  double get subtotal =>
      items.fold(0.0, (s, i) => s + (i.quantity * i.unitPrice - i.discount));

  // ── Item management ───────────────────────────────────────────────────────

  void addItem() {
    items.add(_ItemDraft());
  }

  void removeItem(int index) {
    if (items.length > 1) items.removeAt(index);
  }

  void updateItem(int index, _ItemDraft item) {
    items[index] = item;
    items.refresh();
  }

  // ── Submission ────────────────────────────────────────────────────────────

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (items.isEmpty) {
      showError('Add at least one item');
      return;
    }

    final invalidItems = items
        .where(
          (i) =>
              i.productNameCtrl.text.trim().isEmpty ||
              i.skuCtrl.text.trim().isEmpty ||
              i.quantity < 1,
        )
        .toList();
    if (invalidItems.isNotEmpty) {
      showError('Please fill all item fields');
      return;
    }

    isSubmitting.value = true;
    try {
      final input = CreateOrderInput(
        customerId: customerIdCtrl.text.trim(),
        customerName: customerNameCtrl.text.trim(),
        customerEmail: customerEmailCtrl.text.trim(),
        notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
        currency: currency.value,
        paymentMethod: paymentMethod.value,
        items: items
            .map((i) => CreateOrderItemInput(
                  productId: i.productIdCtrl.text.trim(),
                  productName: i.productNameCtrl.text.trim(),
                  sku: i.skuCtrl.text.trim(),
                  quantity: i.quantity,
                  unitPrice: i.unitPrice,
                  discount: i.discount,
                  notes: i.notesCtrl.text.trim().isEmpty
                      ? null
                      : i.notesCtrl.text.trim(),
                ))
            .toList(),
      );

      await _repo.createOrder(input);
      showSuccess('Order created successfully');
      Get.back(result: true);
    } catch (e) {
      showError(e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    customerIdCtrl.dispose();
    customerNameCtrl.dispose();
    customerEmailCtrl.dispose();
    notesCtrl.dispose();
    for (final item in items) {
      item.dispose();
    }
    super.onClose();
  }
}

// ── Item draft ────────────────────────────────────────────────────────────────

class _ItemDraft {
  final productIdCtrl = TextEditingController();
  final productNameCtrl = TextEditingController();
  final skuCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final quantityCtrl = TextEditingController(text: '1');
  final unitPriceCtrl = TextEditingController(text: '0.00');
  final discountCtrl = TextEditingController(text: '0');

  int get quantity => int.tryParse(quantityCtrl.text) ?? 1;
  double get unitPrice => double.tryParse(unitPriceCtrl.text) ?? 0;
  double get discount => double.tryParse(discountCtrl.text) ?? 0;
  double get total => quantity * unitPrice - discount;

  void dispose() {
    productIdCtrl.dispose();
    productNameCtrl.dispose();
    skuCtrl.dispose();
    notesCtrl.dispose();
    quantityCtrl.dispose();
    unitPriceCtrl.dispose();
    discountCtrl.dispose();
  }
}

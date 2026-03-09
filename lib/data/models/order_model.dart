// lib/data/models/order_model.dart

import 'package:equatable/equatable.dart';

// ── Order status ──────────────────────────────────────────────────────────────

enum OrderStatus {
  pending(0, 'Pending'),
  confirmed(1, 'Confirmed'),
  processing(2, 'Processing'),
  shipped(3, 'Shipped'),
  delivered(4, 'Delivered'),
  cancelled(5, 'Cancelled'),
  refunded(6, 'Refunded');

  const OrderStatus(this.value, this.label);
  final int value;
  final String label;

  static OrderStatus fromInt(int v) => OrderStatus.values
      .firstWhere((s) => s.value == v, orElse: () => OrderStatus.pending);
}

// ── OrderItem ─────────────────────────────────────────────────────────────────

class OrderItem extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double discount;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.discount,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        id: j['id'] as String,
        productId: j['productId'] as String,
        productName: j['productName'] as String,
        sku: j['sku'] as String,
        quantity: j['quantity'] as int,
        unitPrice: (j['unitPrice'] as num).toDouble(),
        totalPrice: (j['totalPrice'] as num).toDouble(),
        discount: (j['discount'] as num).toDouble(),
        notes: j['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'totalPrice': totalPrice,
        'discount': discount,
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [id, productId, quantity, unitPrice];
}

// ── ShippingAddress ───────────────────────────────────────────────────────────

class ShippingAddress extends Equatable {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;

  const ShippingAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> j) => ShippingAddress(
        street: j['street'] as String,
        city: j['city'] as String,
        state: j['state'] as String,
        country: j['country'] as String,
        postalCode: j['postalCode'] as String,
      );

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
      };

  @override
  List<Object?> get props => [street, city, country, postalCode];
}

// ── Order ─────────────────────────────────────────────────────────────────────

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final OrderStatus status;
  final double totalAmount;
  final double subTotal;
  final double taxAmount;
  final double shippingCost;
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final String? completedAt;
  final String? cancelledAt;
  final String? cancellationReason;
  final List<OrderItem> items;
  final ShippingAddress? shippingAddress;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.status,
    required this.totalAmount,
    required this.subTotal,
    required this.taxAmount,
    required this.shippingCost,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    required this.items,
    this.shippingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        orderNumber: j['orderNumber'] as String,
        customerId: j['customerId'] as String,
        customerName: j['customerName'] as String,
        customerEmail: j['customerEmail'] as String,
        status: OrderStatus.fromInt(j['status'] as int),
        totalAmount: (j['totalAmount'] as num).toDouble(),
        subTotal: (j['subTotal'] as num).toDouble(),
        taxAmount: (j['taxAmount'] as num).toDouble(),
        shippingCost: (j['shippingCost'] as num).toDouble(),
        notes: j['notes'] as String?,
        createdAt: j['createdAt'] as String,
        updatedAt: j['updatedAt'] as String?,
        completedAt: j['completedAt'] as String?,
        cancelledAt: j['cancelledAt'] as String?,
        cancellationReason: j['cancellationReason'] as String?,
        items: (j['items'] as List<dynamic>)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        shippingAddress: j['shippingAddress'] != null
            ? ShippingAddress.fromJson(
                j['shippingAddress'] as Map<String, dynamic>)
            : null,
      );

  bool get isCancellable =>
      status != OrderStatus.cancelled &&
      status != OrderStatus.delivered &&
      status != OrderStatus.refunded;

  @override
  List<Object?> get props => [id, orderNumber, status, totalAmount];
}

// ── Create inputs ─────────────────────────────────────────────────────────────

class CreateOrderItemInput {
  final String productId;
  final String productName;
  final String sku;
  final int quantity;
  final double unitPrice;
  final double discount;
  final String? notes;

  const CreateOrderItemInput({
    required this.productId,
    required this.productName,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
    this.discount = 0,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'sku': sku,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'discount': discount,
        if (notes != null) 'notes': notes,
      };
}

class CreateOrderInput {
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? notes;
  final String currency;
  final String paymentMethod;
  final List<CreateOrderItemInput> items;
  final ShippingAddress? shippingAddress;

  const CreateOrderInput({
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.currency,
    required this.paymentMethod,
    required this.items,
    this.notes,
    this.shippingAddress,
  });

  Map<String, dynamic> toJson() => {
        'customerId': customerId,
        'customerName': customerName,
        'customerEmail': customerEmail,
        'currency': currency,
        'paymentMethod': paymentMethod,
        'notes': notes,
        'items': items.map((i) => i.toJson()).toList(),
        if (shippingAddress != null)
          'shippingAddress': shippingAddress!.toJson(),
      };
}

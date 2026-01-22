import 'order_item_model.dart';
import 'shipping_address_model.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
  paid;

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      case 'paid':
        return OrderStatus.paid;
      default:
        return OrderStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.paid:
        return 'Paid';
    }
  }
}

enum PaymentMethod {
  telebirr,
  cbebirr,
  cbebank;

  static PaymentMethod fromString(String method) {
    switch (method.toLowerCase()) {
      case 'telebirr':
        return PaymentMethod.telebirr;
      case 'cbebirr':
      case 'cbe_birr':
        return PaymentMethod.cbebirr;
      case 'cbebank':
      case 'cbe_bank':
        return PaymentMethod.cbebank;
      default:
        throw Exception('Unknown payment method: $method');
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cbebirr:
        return 'CBE Birr';
      case PaymentMethod.cbebank:
        return 'CBE Transaction';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'telebirr';
      case PaymentMethod.cbebirr:
        return 'cbebirr';
      case PaymentMethod.cbebank:
        return 'cbebank';
    }
  }
}

class Order {
  final int? id;
  final String? orderNumber;
  final List<OrderItem> items;
  final double totalAmount;
  final PaymentMethod? paymentMethod;
  final ShippingAddress shippingAddress;
  final String? notes;
  final OrderStatus status;
  final String? transactionId;
  final bool? paymentVerified;
  final DateTime? paymentVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;
  final DateTime? estimatedDelivery;

  Order({
    this.id,
    this.orderNumber,
    required this.items,
    required this.totalAmount,
    this.paymentMethod,
    required this.shippingAddress,
    this.notes,
    this.status = OrderStatus.pending,
    this.transactionId,
    this.paymentVerified,
    this.paymentVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.trackingNumber,
    this.estimatedDelivery,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'] ?? json['order_number'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: _parseDouble(json['totalAmount'] ?? json['total_amount']),
      paymentMethod: json['paymentMethod'] != null || json['payment_method'] != null
          ? PaymentMethod.fromString(json['paymentMethod'] ?? json['payment_method'])
          : null,
      shippingAddress: ShippingAddress.fromJson(
        json['shippingAddress'] ?? json['shipping_address'] ?? {},
      ),
      notes: json['notes'],
      status: OrderStatus.fromString(json['status'] ?? 'pending'),
      transactionId: json['transactionId'] ?? json['transaction_id'],
      paymentVerified: json['paymentVerified'] ?? json['payment_verified'],
      paymentVerifiedAt: _parseDateTime(json['paymentVerifiedAt'] ?? json['payment_verified_at']),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseDateTime(json['updatedAt'] ?? json['updated_at']),
      trackingNumber: json['trackingNumber'] ?? json['tracking_number'],
      estimatedDelivery: _parseDateTime(json['estimatedDelivery'] ?? json['estimated_delivery']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (orderNumber != null) 'orderNumber': orderNumber,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.apiValue,
      'shippingAddress': shippingAddress.toJson(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'status': status.name,
      if (transactionId != null) 'transactionId': transactionId,
      if (paymentVerified != null) 'paymentVerified': paymentVerified,
      if (paymentVerifiedAt != null) 'paymentVerifiedAt': paymentVerifiedAt!.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (trackingNumber != null) 'trackingNumber': trackingNumber,
      if (estimatedDelivery != null)
        'estimatedDelivery': estimatedDelivery!.toIso8601String(),
    };
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    List<OrderItem>? items,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    ShippingAddress? shippingAddress,
    String? notes,
    OrderStatus? status,
    String? transactionId,
    bool? paymentVerified,
    DateTime? paymentVerifiedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? trackingNumber,
    DateTime? estimatedDelivery,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      paymentVerified: paymentVerified ?? this.paymentVerified,
      paymentVerifiedAt: paymentVerifiedAt ?? this.paymentVerifiedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, orderNumber: $orderNumber, items: ${items.length}, totalAmount: $totalAmount, status: $status)';
  }

  // Helper getters
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
  
  String get displayOrderNumber => orderNumber ?? (id != null ? 'ORD${id.toString().padLeft(6, '0')}' : 'PENDING');
  
  bool get canBeCancelled => status == OrderStatus.pending || status == OrderStatus.confirmed;
  
  bool get isCompleted => status == OrderStatus.delivered || status == OrderStatus.paid;
  
  bool get requiresPayment => paymentMethod == PaymentMethod.telebirr && transactionId == null;

  // Helper methods to parse values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
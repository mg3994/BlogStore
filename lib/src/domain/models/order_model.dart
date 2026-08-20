import 'cart_item.dart';

class OrderModel {
  final String orderId;
  final String blogId;
  final String? customerEmail;
  final String? customerPhone;
  final Map<String, dynamic> shippingAddress;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.orderId,
    required this.blogId,
    this.customerEmail,
    this.customerPhone,
    required this.shippingAddress,
    required this.items,
    required this.subtotal,
    this.tax = 0.0,
    required this.totalAmount,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'blogId': blogId,
        'customerEmail': customerEmail,
        'customerPhone': customerPhone,
        'shippingAddress': shippingAddress,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'tax': tax,
        'totalAmount': totalAmount,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        orderId: json['orderId'] as String? ?? '',
        blogId: json['blogId'] as String? ?? '',
        customerEmail: json['customerEmail'] as String?,
        customerPhone: json['customerPhone'] as String?,
        shippingAddress: (json['shippingAddress'] as Map<String, dynamic>?) ?? const {},
        items: (json['items'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((i) => CartItem.fromJson(i))
                .toList() ??
            const [],
        subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
        tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        status: json['status'] as String? ?? 'pending',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      );
}

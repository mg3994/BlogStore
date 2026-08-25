import 'product_add_on.dart';

class CartItem {
  final String id;
  final String postId;
  final String blogId;
  final String title;
  final String? imageUrl;
  final double unitPrice;
  final int quantity;
  final List<SelectedAddOn> selectedAddOns;
  final Map<String, String> selectedVariantOptions;
  final DateTime addedAt;

  const CartItem({
    required this.id,
    required this.postId,
    required this.blogId,
    required this.title,
    this.imageUrl,
    required this.unitPrice,
    this.quantity = 1,
    this.selectedAddOns = const [],
    this.selectedVariantOptions = const {},
    required this.addedAt,
  });

  double get addOnsUnitPriceAdjustment {
    double total = 0.0;
    for (final addOn in selectedAddOns) {
      total += addOn.totalPriceAdjustment;
    }
    return total;
  }

  double get effectiveUnitPrice => unitPrice + addOnsUnitPriceAdjustment;

  double get totalPrice => effectiveUnitPrice * quantity;

  CartItem copyWith({
    String? id,
    String? postId,
    String? blogId,
    String? title,
    String? imageUrl,
    double? unitPrice,
    int? quantity,
    List<SelectedAddOn>? selectedAddOns,
    Map<String, String>? selectedVariantOptions,
    DateTime? addedAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      blogId: blogId ?? this.blogId,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      selectedAddOns: selectedAddOns ?? this.selectedAddOns,
      selectedVariantOptions: selectedVariantOptions ?? this.selectedVariantOptions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'blogId': blogId,
        'title': title,
        'imageUrl': imageUrl,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'selectedAddOns': selectedAddOns.map((s) => s.toJson()).toList(),
        'selectedVariantOptions': selectedVariantOptions,
        'addedAt': addedAt.toIso8601String(),
        'totalPrice': totalPrice,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String? ?? '',
        postId: json['postId'] as String? ?? '',
        blogId: json['blogId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        selectedAddOns: (json['selectedAddOns'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((s) => SelectedAddOn.fromJson(s))
                .toList() ??
            const [],
        selectedVariantOptions: (json['selectedVariantOptions'] as Map?)
                ?.map((k, v) => MapEntry(k.toString(), v.toString())) ??
            const {},
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

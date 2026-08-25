import '../domain/models/cart_item.dart';

class QuantityConstraint {
  final int? minQuantity;
  final int? maxQuantity;
  final bool inStock;

  const QuantityConstraint({
    this.minQuantity,
    this.maxQuantity,
    this.inStock = true,
  });
}

class CartItemValidator {
  /// Checks if a single cart item's quantity satisfies minimum and maximum limits.
  static bool isQuantityValid(
    int quantity, {
    int? minQuantity,
    int? maxQuantity,
  }) {
    if (quantity <= 0) return false;
    if (minQuantity != null && quantity < minQuantity) return false;
    if (maxQuantity != null && quantity > maxQuantity) return false;
    return true;
  }

  /// Validates all items in cart against their individual constraints.
  /// Returns a map of cartItemId -> error string for invalid items.
  static Map<String, String> validateCart({
    required List<CartItem> cartItems,
    Map<String, QuantityConstraint> constraints = const {},
  }) {
    final Map<String, String> errors = {};

    for (final item in cartItems) {
      final constraint = constraints[item.id] ?? constraints[item.postId];
      if (constraint != null) {
        if (!constraint.inStock) {
          errors[item.id] = 'Item is currently out of stock';
          continue;
        }

        if (constraint.minQuantity != null && item.quantity < constraint.minQuantity!) {
          errors[item.id] = 'Minimum quantity required is ${constraint.minQuantity}';
        } else if (constraint.maxQuantity != null && item.quantity > constraint.maxQuantity!) {
          errors[item.id] = 'Maximum allowed quantity is ${constraint.maxQuantity}';
        }
      }
    }

    return errors;
  }
}

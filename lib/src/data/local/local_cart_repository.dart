import '../../../sm.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class LocalCartRepository implements ICartRepository {
  final Signal<List<CartItem>> _cartSignal = signal<List<CartItem>>([]);

  @override
  ReadonlySignal<List<CartItem>> get cartSignal => _cartSignal;

  @override
  List<CartItem> get cartItems => List.unmodifiable(_cartSignal.value);

  @override
  Future<void> addToCart(CartItem item) async {
    final items = List<CartItem>.from(_cartSignal.value);
    final index = items.indexWhere((i) =>
        i.postId == item.postId &&
        _mapEquals(i.selectedVariantOptions, item.selectedVariantOptions) &&
        _selectedAddOnsEquals(i.selectedAddOns, item.selectedAddOns));

    if (index != -1) {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      items.add(item);
    }
    _cartSignal.value = items;
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    final items = List<CartItem>.from(_cartSignal.value);
    final index = items.indexWhere((i) => i.id == cartItemId);
    if (index != -1) {
      items[index] = items[index].copyWith(quantity: quantity);
      _cartSignal.value = items;
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    final items = List<CartItem>.from(_cartSignal.value);
    items.removeWhere((i) => i.id == cartItemId);
    _cartSignal.value = items;
  }

  @override
  Future<void> clearCart() async {
    _cartSignal.value = [];
  }

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }

  bool _selectedAddOnsEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].optionId != b[i].optionId) return false;
    }
    return true;
  }
}

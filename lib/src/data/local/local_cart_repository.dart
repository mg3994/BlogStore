import 'dart:async';
import '../../domain/models/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class LocalCartRepository implements ICartRepository {
  final List<CartItem> _items = [];
  final StreamController<List<CartItem>> _controller = StreamController<List<CartItem>>.broadcast();

  LocalCartRepository() {
    _controller.add(List.unmodifiable(_items));
  }

  void _notify() {
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Stream<List<CartItem>> watchCart() => _controller.stream;

  @override
  Future<List<CartItem>> getCartItems() async => List.unmodifiable(_items);

  @override
  Future<void> addToCart(CartItem item) async {
    final index = _items.indexWhere((i) =>
        i.postId == item.postId &&
        _mapEquals(i.selectedVariantOptions, item.selectedVariantOptions) &&
        _selectedAddOnsEquals(i.selectedAddOns, item.selectedAddOns));

    if (index != -1) {
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    } else {
      _items.add(item);
    }
    _notify();
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    final index = _items.indexWhere((i) => i.id == cartItemId);
    if (index != -1) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _notify();
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    _items.removeWhere((i) => i.id == cartItemId);
    _notify();
  }

  @override
  Future<void> clearCart() async {
    _items.clear();
    _notify();
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

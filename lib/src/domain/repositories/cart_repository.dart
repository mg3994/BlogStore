import '../../../sm.dart';
import '../models/cart_item.dart';

abstract class ICartRepository {
  ReadonlySignal<List<CartItem>> get cartSignal;
  List<CartItem> get cartItems;
  Future<void> addToCart(CartItem item);
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart();
}

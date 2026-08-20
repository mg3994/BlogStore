import '../models/cart_item.dart';

abstract class ICartRepository {
  Stream<List<CartItem>> watchCart();
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(CartItem item);
  Future<void> updateQuantity(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
  Future<void> clearCart();
}

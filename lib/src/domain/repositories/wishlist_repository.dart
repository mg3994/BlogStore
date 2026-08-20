import '../models/wishlist_item.dart';

abstract class IWishlistRepository {
  Stream<List<WishlistItem>> watchWishlist();
  Future<List<WishlistItem>> getWishlistItems();
  Future<void> addToWishlist(WishlistItem item);
  Future<void> removeFromWishlist(String wishlistItemId);
  Future<bool> isInWishlist(String postId);
}

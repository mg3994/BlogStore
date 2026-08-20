import '../../../sm.dart';
import '../models/wishlist_item.dart';

abstract class IWishlistRepository {
  ReadonlySignal<List<WishlistItem>> get wishlistSignal;
  List<WishlistItem> get wishlistItems;
  Future<void> addToWishlist(WishlistItem item);
  Future<void> removeFromWishlist(String wishlistItemId);
  Future<bool> isInWishlist(String postId);
}

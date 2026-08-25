import '../../../sm.dart';
import '../../domain/models/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

class LocalWishlistRepository implements IWishlistRepository {
  final Signal<List<WishlistItem>> _wishlistSignal = signal<List<WishlistItem>>([]);

  @override
  ReadonlySignal<List<WishlistItem>> get wishlistSignal => _wishlistSignal;

  @override
  List<WishlistItem> get wishlistItems => List.unmodifiable(_wishlistSignal.value);

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    final items = List<WishlistItem>.from(_wishlistSignal.value);
    if (!items.any((i) => i.postId == item.postId)) {
      items.add(item);
      _wishlistSignal.value = items;
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistItemId) async {
    final items = List<WishlistItem>.from(_wishlistSignal.value);
    items.removeWhere((i) => i.id == wishlistItemId || i.postId == wishlistItemId);
    _wishlistSignal.value = items;
  }

  @override
  Future<bool> isInWishlist(String postId) async {
    return _wishlistSignal.value.any((i) => i.postId == postId);
  }
}

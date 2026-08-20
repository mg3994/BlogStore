import 'dart:async';
import '../../domain/models/wishlist_item.dart';
import '../../domain/repositories/wishlist_repository.dart';

class LocalWishlistRepository implements IWishlistRepository {
  final List<WishlistItem> _items = [];
  final StreamController<List<WishlistItem>> _controller = StreamController<List<WishlistItem>>.broadcast();

  LocalWishlistRepository() {
    _controller.add(List.unmodifiable(_items));
  }

  void _notify() {
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Stream<List<WishlistItem>> watchWishlist() => _controller.stream;

  @override
  Future<List<WishlistItem>> getWishlistItems() async => List.unmodifiable(_items);

  @override
  Future<void> addToWishlist(WishlistItem item) async {
    if (!_items.any((i) => i.postId == item.postId)) {
      _items.add(item);
      _notify();
    }
  }

  @override
  Future<void> removeFromWishlist(String wishlistItemId) async {
    _items.removeWhere((i) => i.id == wishlistItemId || i.postId == wishlistItemId);
    _notify();
  }

  @override
  Future<bool> isInWishlist(String postId) async {
    return _items.any((i) => i.postId == postId);
  }
}

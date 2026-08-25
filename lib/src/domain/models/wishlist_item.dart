class WishlistItem {
  final String id;
  final String postId;
  final String blogId;
  final String title;
  final String? imageUrl;
  final String? price;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.postId,
    required this.blogId,
    required this.title,
    this.imageUrl,
    this.price,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'postId': postId,
        'blogId': blogId,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'addedAt': addedAt.toIso8601String(),
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String? ?? '',
        postId: json['postId'] as String? ?? '',
        blogId: json['blogId'] as String? ?? '',
        title: json['title'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        price: json['price'] as String?,
        addedAt: DateTime.tryParse(json['addedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

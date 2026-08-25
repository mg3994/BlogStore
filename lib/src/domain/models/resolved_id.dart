class ResolvedId {
  final String? blogId;
  final String? postId;
  final String? url;

  const ResolvedId({
    this.blogId,
    this.postId,
    this.url,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedId &&
          runtimeType == other.runtimeType &&
          blogId == other.blogId &&
          postId == other.postId &&
          url == other.url;

  @override
  int get hashCode => blogId.hashCode ^ postId.hashCode ^ url.hashCode;

  @override
  String toString() => 'ResolvedId(blogId: $blogId, postId: $postId, url: $url)';
}

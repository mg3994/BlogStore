import '../models/location_model.dart';

class BloggerPostItem {
  final String id;
  final String blogId;
  final String title;
  final String content;
  final String published;
  final String updated;
  final String? url;
  final List<String> labels;
  final Map<String, dynamic>? jsonLdSchema;

  const BloggerPostItem({
    required this.id,
    required this.blogId,
    required this.title,
    required this.content,
    required this.published,
    required this.updated,
    this.url,
    this.labels = const [],
    this.jsonLdSchema,
  });

  BloggerPostItem copyWith({
    String? id,
    String? blogId,
    String? title,
    String? content,
    String? published,
    String? updated,
    String? url,
    List<String>? labels,
    Map<String, dynamic>? jsonLdSchema,
  }) {
    return BloggerPostItem(
      id: id ?? this.id,
      blogId: blogId ?? this.blogId,
      title: title ?? this.title,
      content: content ?? this.content,
      published: published ?? this.published,
      updated: updated ?? this.updated,
      url: url ?? this.url,
      labels: labels ?? this.labels,
      jsonLdSchema: jsonLdSchema ?? this.jsonLdSchema,
    );
  }
}

class PaginatedBloggerPosts {
  final List<BloggerPostItem> posts;
  final String? nextPageToken;
  final int? nextStartIndex;
  final int totalResults;
  final bool hasMore;

  const PaginatedBloggerPosts({
    required this.posts,
    this.nextPageToken,
    this.nextStartIndex,
    this.totalResults = 0,
    required this.hasMore,
  });
}

abstract class IBloggerRepository {
  Future<BloggerPostItem?> getPostById({
    required String blogId,
    required String postId,
    String? idToken,
  });

  Future<PaginatedBloggerPosts> getPosts({
    String? blogId,
    String? query,
    List<String>? labels,
    LocationModel? userLocation,
    int startIndex = 1,
    int maxResults = 10,
    String? pageToken,
    String? idToken,
  });
}

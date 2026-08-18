import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../domain/models/location_model.dart';
import '../domain/repositories/blogger_repository.dart';
import '../services/blogger_data_service.dart';
import '../services/power_search_parser.dart';

class BloggerRemoteDataSource {
  final Dio dio;
  final BloggerDataService schemaService;

  BloggerRemoteDataSource({
    required this.dio,
    required this.schemaService,
  });

  Future<BloggerPostItem?> fetchPostById({
    required String blogId,
    required String postId,
    String? idToken,
  }) async {
    if (idToken != null && idToken.isNotEmpty) {
      // Blogger REST API v3
      final url = '${EnvConfig.bloggerV3ApiBaseUrl}/blogs/$blogId/posts/$postId';
      try {
        final res = await dio.get(
          url,
          options: Options(headers: {'Authorization': 'Bearer $idToken'}),
        );
        if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
          return _mapV3ItemToPostItem(res.data, blogId);
        }
      } catch (_) {}
    }

    // Unauthenticated Blogger Feeds JSON fallback
    final feedUrl = '${EnvConfig.bloggerFeedsBaseUrl}/$blogId/posts/default/$postId?alt=json';
    try {
      final res = await dio.get(feedUrl);
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        final entry = res.data['entry'];
        if (entry is Map<String, dynamic>) {
          return _mapFeedEntryToPostItem(entry, blogId);
        }
      }
    } catch (_) {}

    return null;
  }

  Future<PaginatedBloggerPosts> fetchPosts({
    String? blogId,
    String? query,
    List<String>? labels,
    LocationModel? userLocation,
    int startIndex = 1,
    int maxResults = 10,
    String? pageToken,
    String? idToken,
  }) async {
    final effectiveBlogId = blogId ?? EnvConfig.defaultBlogId;
    final searchResult = PowerSearchParser.parse(query, location: userLocation);

    final effectiveLabels = <String>[
      if (labels != null) ...labels,
      ...searchResult.labels,
    ];

    if (idToken != null && idToken.isNotEmpty) {
      return _fetchPostsV3Api(
        blogId: effectiveBlogId,
        textQuery: searchResult.textQuery,
        labels: effectiveLabels,
        maxResults: maxResults,
        pageToken: pageToken,
        idToken: idToken,
      );
    } else {
      return _fetchPostsFeedsApi(
        blogId: effectiveBlogId,
        textQuery: searchResult.textQuery,
        labels: effectiveLabels,
        startIndex: startIndex,
        maxResults: maxResults,
      );
    }
  }

  Future<PaginatedBloggerPosts> _fetchPostsV3Api({
    required String blogId,
    required String textQuery,
    required List<String> labels,
    required int maxResults,
    String? pageToken,
    required String idToken,
  }) async {
    final url = '${EnvConfig.bloggerV3ApiBaseUrl}/blogs/$blogId/posts';
    final queryParams = <String, dynamic>{
      'maxResults': maxResults,
      if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
      if (textQuery.isNotEmpty) 'q': textQuery,
      if (labels.isNotEmpty) 'labels': labels.join(','),
    };

    final res = await dio.get(
      url,
      queryParameters: queryParams,
      options: Options(headers: {'Authorization': 'Bearer $idToken'}),
    );

    final data = res.data as Map<String, dynamic>? ?? {};
    final itemsJson = (data['items'] as List?) ?? [];
    final nextPageToken = data['nextPageToken'] as String?;

    final posts = itemsJson
        .whereType<Map<String, dynamic>>()
        .map((item) => _mapV3ItemToPostItem(item, blogId))
        .toList();

    return PaginatedBloggerPosts(
      posts: posts,
      nextPageToken: nextPageToken,
      hasMore: nextPageToken != null && nextPageToken.isNotEmpty,
    );
  }

  Future<PaginatedBloggerPosts> _fetchPostsFeedsApi({
    required String blogId,
    required String textQuery,
    required List<String> labels,
    required int startIndex,
    required int maxResults,
  }) async {
    String feedUrl = '${EnvConfig.bloggerFeedsBaseUrl}/$blogId/posts/default';

    if (labels.isNotEmpty) {
      final labelPath = labels.map(Uri.encodeComponent).join('/');
      feedUrl = '$feedUrl/-/$labelPath';
    }

    final queryParams = <String, dynamic>{
      'alt': 'json',
      'start-index': startIndex,
      'max-results': maxResults,
      if (textQuery.isNotEmpty) 'q': textQuery,
    };

    final res = await dio.get(
      feedUrl,
      queryParameters: queryParams,
    );

    final data = res.data as Map<String, dynamic>? ?? {};
    final feed = data['feed'] as Map<String, dynamic>? ?? {};
    final entries = (feed['entry'] as List?) ?? [];

    int totalResults = 0;
    final totalResultsNode = feed['openSearch\$totalResults'];
    if (totalResultsNode is Map<String, dynamic>) {
      totalResults = int.tryParse(totalResultsNode['\$t']?.toString() ?? '0') ?? 0;
    }

    final posts = entries
        .whereType<Map<String, dynamic>>()
        .map((entry) => _mapFeedEntryToPostItem(entry, blogId))
        .toList();

    final nextStartIndex = startIndex + posts.length;
    final hasMore = totalResults > 0 ? (startIndex + posts.length - 1) < totalResults : posts.length >= maxResults;

    return PaginatedBloggerPosts(
      posts: posts,
      nextStartIndex: nextStartIndex,
      totalResults: totalResults,
      hasMore: hasMore,
    );
  }

  BloggerPostItem _mapFeedEntryToPostItem(Map<String, dynamic> entry, String blogId) {
    final idString = entry['id']?['\$t'] as String? ?? '';
    final postId = idString.contains('post-')
        ? idString.split('post-').last
        : (idString.split('/').last);

    final title = entry['title']?['\$t'] as String? ?? '';
    final content = entry['content']?['\$t'] as String? ?? '';
    final published = entry['published']?['\$t'] as String? ?? '';
    final updated = entry['updated']?['\$t'] as String? ?? '';

    final categories = (entry['category'] as List?) ?? [];
    final labels = categories
        .whereType<Map<String, dynamic>>()
        .map((cat) => cat['term'] as String? ?? '')
        .where((term) => term.isNotEmpty)
        .toList();

    final links = (entry['link'] as List?) ?? [];
    String? alternateUrl;
    for (final link in links) {
      if (link is Map<String, dynamic> && link['rel'] == 'alternate') {
        alternateUrl = link['href'] as String?;
        break;
      }
    }

    final schema = schemaService.extractJsonLd(content);

    return BloggerPostItem(
      id: postId,
      blogId: blogId,
      title: title,
      content: content,
      published: published,
      updated: updated,
      url: alternateUrl,
      labels: labels,
      jsonLdSchema: schema,
    );
  }

  BloggerPostItem _mapV3ItemToPostItem(Map<String, dynamic> item, String blogId) {
    final id = item['id'] as String? ?? '';
    final title = item['title'] as String? ?? '';
    final content = item['content'] as String? ?? '';
    final published = item['published'] as String? ?? '';
    final updated = item['updated'] as String? ?? '';
    final url = item['url'] as String?;

    final labelsRaw = item['labels'] as List?;
    final labels = labelsRaw?.whereType<String>().toList() ?? [];

    final schema = schemaService.extractJsonLd(content);

    return BloggerPostItem(
      id: id,
      blogId: blogId,
      title: title,
      content: content,
      published: published,
      updated: updated,
      url: url,
      labels: labels,
      jsonLdSchema: schema,
    );
  }
}

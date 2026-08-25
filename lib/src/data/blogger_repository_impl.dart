import '../domain/models/location_model.dart';
import '../domain/repositories/blogger_repository.dart';
import '../services/area_served_matcher.dart';
import 'blogger_remote_data_source.dart';

class BloggerRepositoryImpl implements IBloggerRepository {
  final BloggerRemoteDataSource remoteDataSource;

  BloggerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BloggerPostItem?> getPostById({
    required String blogId,
    required String postId,
    String? idToken,
  }) async {
    return remoteDataSource.fetchPostById(
      blogId: blogId,
      postId: postId,
      idToken: idToken,
    );
  }

  @override
  Future<PaginatedBloggerPosts> getPosts({
    String? blogId,
    String? query,
    List<String>? labels,
    LocationModel? userLocation,
    int startIndex = 1,
    int maxResults = 10,
    String? pageToken,
    String? idToken,
  }) async {
    final result = await remoteDataSource.fetchPosts(
      blogId: blogId,
      query: query,
      labels: labels,
      userLocation: userLocation,
      startIndex: startIndex,
      maxResults: maxResults,
      pageToken: pageToken,
      idToken: idToken,
    );

    if (userLocation == null) {
      return result;
    }

    // Filter posts by areaServed matching if location is set and schema exists
    final filteredPosts = result.posts.where((post) {
      final schema = post.jsonLdSchema;
      if (schema == null) return true;
      final areaServed = schema['areaServed'];
      return AreaServedMatcher.isServiceable(
        areaServed: areaServed,
        userLocation: userLocation,
      );
    }).toList();

    return PaginatedBloggerPosts(
      posts: filteredPosts,
      nextPageToken: result.nextPageToken,
      nextStartIndex: result.nextStartIndex,
      totalResults: result.totalResults,
      hasMore: result.hasMore,
    );
  }
}

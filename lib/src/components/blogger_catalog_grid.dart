import 'package:flutter/material.dart';
import '../domain/repositories/blogger_repository.dart';
import 'product_card.dart';

class BloggerCatalogGrid extends StatelessWidget {
  final List<BloggerPostItem> posts;
  final bool isLoadingMore;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final ValueChanged<BloggerPostItem>? onPostTap;

  const BloggerCatalogGrid({
    super.key,
    required this.posts,
    this.isLoadingMore = false,
    this.hasMore = false,
    required this.onLoadMore,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No serviceable products found.'),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoadingMore &&
            hasMore &&
            scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return ProductCard(
                    post: post,
                    onTap: onPostTap != null ? () => onPostTap!(post) : null,
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
          if (isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

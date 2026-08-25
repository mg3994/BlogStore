import 'package:flutter/material.dart';
import '../domain/repositories/blogger_repository.dart';
import '../services/schema_i18n_resolver.dart';

class ProductCard extends StatelessWidget {
  final BloggerPostItem post;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final schema = post.jsonLdSchema;
    final title = SchemaI18nResolver.resolve(schema?['name'] ?? post.title);
    final description = SchemaI18nResolver.resolve(schema?['description'] ?? '');

    String? imageUrl;
    final imageNode = schema?['image'];
    if (imageNode is String) {
      imageUrl = imageNode;
    } else if (imageNode is List && imageNode.isNotEmpty) {
      imageUrl = imageNode.first is String ? imageNode.first : imageNode.first?['url'];
    } else if (imageNode is Map<String, dynamic>) {
      imageUrl = imageNode['url'] as String?;
    }

    final price = schema?['offers']?['price']?.toString() ?? schema?['price']?.toString();
    final currency = schema?['offers']?['priceCurrency']?.toString() ?? 'INR';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.shopping_bag_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (price != null)
                        Text(
                          '$currency $price',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        )
                      else
                        const SizedBox.shrink(),
                      if (post.labels.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            post.labels.first,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../domain/models/resolved_id.dart';
import 'schema_override.dart';

typedef Fetcher = Future<String?> Function(String url, {Map<String, String>? headers});

class BloggerDataService {
  final Dio? dio;
  final Fetcher? customFetcher;

  BloggerDataService({this.dio, this.customFetcher});

  /// Decodes common HTML entities found in post bodies.
  static String decodeEntities(String text) {
    if (text.isEmpty) return '';
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#91;', '[')
        .replaceAll('&#93;', ']');
  }

  /// Extracts JSON-LD from a post content string (with or without script tags).
  Map<String, dynamic>? extractJsonLd(String content) {
    if (content.isEmpty) return null;

    try {
      final scriptRegex = RegExp(
        r'<script[^>]*type=["' "'" r']application\/ld\+json["' "'" r'][^>]*>([\s\S]*?)<\/script>',
        caseSensitive: false,
      );
      final match = scriptRegex.firstMatch(content);
      String jsonContent = match != null ? match.group(1)! : content;

      jsonContent = decodeEntities(jsonContent).trim();

      // Basic sanitizer for JSON-LD comments /* css-like */
      final cleaned = jsonContent.replaceAll(RegExp(r'\/\*[\s\S]*?\*\/'), '').trim();

      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Substring fallback for direct JSON starting with { and ending with }
      try {
        final start = content.indexOf('{');
        final end = content.lastIndexOf('}');
        if (start != -1 && end != -1 && end > start) {
          final candidate = decodeEntities(content.substring(start, end + 1));
          final decoded = jsonDecode(candidate);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
        }
      } catch (_) {
        // Fallback ignored
      }
    }
    return null;
  }

  /// Fetches search autocomplete suggestions based on power search query (preserving `label:` context).
  Future<List<String>> fetchSearchSuggestions(
    String query, {
    String? blogId,
    int maxResults = 10,
  }) async {
    if (query.trim().length < 2) return const [];

    final effectiveBlogId = blogId ?? EnvConfig.defaultBlogId;

    try {
      final labelRegex = RegExp(r'label:([^|\s]+)');
      final matches = labelRegex.allMatches(query).toList();

      String labelPrefix = '';
      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        labelPrefix = query.substring(0, lastMatch.end).trim() + ' ';
        if (query.trim().endsWith('|')) {
          labelPrefix = query.trim() + ' ';
        }
      }

      final cleanedKeyword = query
          .replaceAll(labelRegex, '')
          .replaceAll('|', '')
          .trim()
          .toLowerCase();

      final feedUrl = '${EnvConfig.bloggerFeedsBaseUrl}/$effectiveBlogId/posts/default?alt=json&max-results=50&q=${Uri.encodeComponent(cleanedKeyword)}';

      final bodyText = await _fetchUrlText(feedUrl);
      if (bodyText == null || bodyText.isEmpty) return const [];

      final data = jsonDecode(bodyText);
      final entries = (data['feed']?['entry'] as List?) ?? [];

      final Set<String> suggestions = {};

      for (final entry in entries) {
        if (entry is Map<String, dynamic>) {
          final title = entry['title']?['\$t'] as String? ?? '';
          if (cleanedKeyword.isEmpty || title.toLowerCase().contains(cleanedKeyword)) {
            suggestions.add('$labelPrefix$title'.trim());
          }

          final content = entry['content']?['\$t'] as String? ?? '';
          final schema = extractJsonLd(content);
          if (schema != null) {
            final name = schema['name'] as String?;
            if (name != null && (cleanedKeyword.isEmpty || name.toLowerCase().contains(cleanedKeyword))) {
              suggestions.add('$labelPrefix$name'.trim());
            }

            final keywords = schema['keywords'];
            if (keywords is String) {
              for (final k in keywords.split(',')) {
                final trimmed = k.trim();
                if (trimmed.isNotEmpty && (cleanedKeyword.isEmpty || trimmed.toLowerCase().contains(cleanedKeyword))) {
                  suggestions.add('$labelPrefix$trimmed'.trim());
                }
              }
            }
          }
        }
      }

      return suggestions.take(maxResults).toList();
    } catch (_) {}

    return const [];
  }

  /// Fetches a Blogger post's JSON schema.
  /// If authenticated (`idToken` provided), requests the v3 REST API endpoint.
  /// Otherwise, requests the unauthenticated JSON feed endpoint.
  Future<Map<String, dynamic>?> fetchPostSchema({
    required String blogId,
    required String postId,
    String? idToken,
  }) async {
    if (idToken != null && idToken.isNotEmpty) {
      // Authenticated Blogger REST API v3
      final url = '${EnvConfig.bloggerV3ApiBaseUrl}/blogs/$blogId/posts/$postId';
      try {
        final bodyText = await _fetchUrlText(
          url,
          headers: {'Authorization': 'Bearer $idToken'},
        );
        if (bodyText != null && bodyText.isNotEmpty) {
          final data = jsonDecode(bodyText);
          if (data is Map<String, dynamic>) {
            final content = data['content'] as String? ?? '';
            return extractJsonLd(content);
          }
        }
      } catch (_) {}
    }

    // Unauthenticated Blogger Feeds JSON
    final url = '${EnvConfig.bloggerFeedsBaseUrl}/$blogId/posts/default/$postId?alt=json';
    try {
      final bodyText = await _fetchUrlText(url);
      if (bodyText == null || bodyText.isEmpty) return null;

      final data = jsonDecode(bodyText);
      if (data is Map<String, dynamic>) {
        final entry = data['entry'];
        if (entry is Map<String, dynamic>) {
          final content = entry['content']?['\$t'] as String? ?? '';
          return extractJsonLd(content);
        }
      }
    } catch (_) {}
    return null;
  }

  /// Recursively resolves all `@id` references in a schema, fetches remote references,
  /// and merges local overrides.
  Future<Map<String, dynamic>> resolveAndLoadSchema(
    Map<String, dynamic> schema, {
    required String base,
    String? idToken,
  }) async {
    final Map<String, dynamic> resolved = jsonDecode(jsonEncode(schema));
    await _traverseAndResolve(resolved, base, idToken: idToken);
    return resolved;
  }

  Future<void> _traverseAndResolve(
    dynamic node,
    String base, {
    String? idToken,
  }) async {
    if (node is Map<String, dynamic>) {
      final idValue = node['@id'] ?? node['id'];

      if (idValue is String && idValue.trim().isNotEmpty) {
        final ResolvedId resolvedId = SchemaOverride.resolveId(base, idValue.trim());
        final blogId = resolvedId.blogId;
        final postId = resolvedId.postId;
        final fullUrl = resolvedId.url;

        Map<String, dynamic>? fetchedSchema;

        if (blogId != null && postId != null) {
          fetchedSchema = await fetchPostSchema(
            blogId: blogId,
            postId: postId,
            idToken: idToken,
          );
        } else if (fullUrl != null) {
          try {
            final bodyText = await _fetchUrlText(
              fullUrl,
              headers: idToken != null && idToken.isNotEmpty
                  ? {'Authorization': 'Bearer $idToken'}
                  : null,
            );
            if (bodyText != null) {
              fetchedSchema = extractJsonLd(bodyText);
            }
          } catch (_) {}
        }

        if (fetchedSchema != null) {
          final nestedBase = (blogId != null && postId != null) ? '$blogId/$postId' : base;

          fetchedSchema = await resolveAndLoadSchema(
            fetchedSchema,
            base: nestedBase,
            idToken: idToken,
          );

          final merged = SchemaOverride.deepMerge(fetchedSchema, Map<String, dynamic>.from(node));

          node.clear();
          node.addAll(merged);
          return;
        }
      }

      for (final key in List<String>.from(node.keys)) {
        final val = node[key];
        if (val is Map<String, dynamic> || val is List) {
          await _traverseAndResolve(val, base, idToken: idToken);
        }
      }
    } else if (node is List) {
      for (int i = 0; i < node.length; i++) {
        final item = node[i];
        if (item is Map<String, dynamic> || item is List) {
          await _traverseAndResolve(item, base, idToken: idToken);
        }
      }
    }
  }

  Future<String?> _fetchUrlText(String url, {Map<String, String>? headers}) async {
    if (customFetcher != null) {
      return await customFetcher!(url, headers: headers);
    }
    if (dio != null) {
      final res = await dio!.get(
        url,
        options: headers != null ? Options(headers: headers) : null,
      );
      if (res.statusCode == 200) {
        return res.data is String ? res.data : jsonEncode(res.data);
      }
    }
    return null;
  }
}

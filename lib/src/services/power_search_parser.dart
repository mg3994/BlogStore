import '../domain/models/location_model.dart';

class PowerSearchResult {
  final List<String> labels;
  final String textQuery;
  final String combinedQuery;

  const PowerSearchResult({
    required this.labels,
    required this.textQuery,
    required this.combinedQuery,
  });

  @override
  String toString() =>
      'PowerSearchResult(labels: $labels, textQuery: $textQuery, combinedQuery: $combinedQuery)';
}

class PowerSearchParser {
  /// Parses a raw user search input containing label filters (e.g. `label:electronics|label:fashion`
  /// or space-separated `label:sale text`) and optional user location.
  static PowerSearchResult parse(
    String? rawQuery, {
    LocationModel? location,
  }) {
    if (rawQuery == null || rawQuery.trim().isEmpty) {
      final locQuery = location?.primarySearchQuery ?? '';
      return PowerSearchResult(
        labels: const [],
        textQuery: locQuery,
        combinedQuery: locQuery,
      );
    }

    final trimmed = rawQuery.trim();
    final labels = <String>{};
    final textParts = <String>[];

    // Handle pipe-separated segments or space-separated tokens
    final segments = trimmed.split('|');

    for (final segment in segments) {
      final tokens = segment.trim().split(RegExp(r'\s+'));
      for (final token in tokens) {
        if (token.startsWith('label:')) {
          final labelVal = token.substring('label:'.length).trim();
          if (labelVal.isNotEmpty) {
            labels.add(labelVal);
          }
        } else if (token.isNotEmpty) {
          textParts.add(token);
        }
      }
    }

    String baseTextQuery = textParts.join(' ').trim();
    final locQuery = location?.primarySearchQuery;

    if (locQuery != null && locQuery.isNotEmpty) {
      if (baseTextQuery.isNotEmpty) {
        baseTextQuery = '$baseTextQuery $locQuery';
      } else {
        baseTextQuery = locQuery;
      }
    }

    final List<String> labelList = labels.toList();
    final String combinedQuery = [
      if (labelList.isNotEmpty) labelList.map((l) => 'label:$l').join('|'),
      if (baseTextQuery.isNotEmpty) baseTextQuery,
    ].join(' ').trim();

    return PowerSearchResult(
      labels: labelList,
      textQuery: baseTextQuery,
      combinedQuery: combinedQuery,
    );
  }
}

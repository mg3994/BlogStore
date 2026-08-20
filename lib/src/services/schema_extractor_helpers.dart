class SchemaExtractorHelpers {
  /// Extracts delivery lead time in minutes from schema data.
  static int extractLeadTimeMinutes(Map<String, dynamic>? schema) {
    if (schema == null) return 0;

    final lt = schema['deliveryLeadTime'] ??
        schema['offers']?['deliveryLeadTime'] ??
        schema['itemOffered']?['offers']?['deliveryLeadTime'];

    if (lt == null) return 0;

    if (lt is Map<String, dynamic>) {
      final val = (lt['value'] as num?)?.toInt() ?? 0;
      final unit = (lt['unitCode'] ?? lt['unitText'])?.toString().toUpperCase() ?? 'MIN';

      if (unit == 'HUR' || unit == 'HOUR' || unit == 'HOURS') return val * 60;
      if (unit == 'DAY' || unit == 'DAYS') return val * 24 * 60;
      return val;
    }

    final str = lt.toString().toLowerCase();
    final numStr = RegExp(r'\d+').firstMatch(str)?.group(0);
    final val = int.tryParse(numStr ?? '') ?? 0;

    if (str.contains('hour')) return val * 60;
    if (str.contains('day')) return val * 24 * 60;
    return val;
  }

  /// Extracts item condition string (e.g. New, Refurbished, Used, Damaged).
  static String? extractItemCondition(Map<String, dynamic>? schema) {
    if (schema == null) return null;

    final cond = schema['itemCondition'] ??
        schema['offers']?['itemCondition'] ??
        schema['itemOffered']?['itemCondition'];

    if (cond == null) return null;

    final str = cond.toString().toLowerCase();
    if (str.contains('newcondition')) return 'New';
    if (str.contains('refurbishedcondition')) return 'Refurbished';
    if (str.contains('usedcondition')) return 'Used';
    if (str.contains('damagedcondition')) return 'Damaged';

    return str.split('/').last;
  }

  /// Extracts 3D Model GLTF/GLB content URL from schema.
  static String? extract3DModelUrl(Map<String, dynamic>? schema) {
    if (schema == null) return null;

    final subjectOf = schema['subjectOf'];
    if (subjectOf is List) {
      for (final item in subjectOf) {
        if (item is Map<String, dynamic> && item['@type'] == '3DModel') {
          final encoding = item['encoding'];
          if (encoding is Map<String, dynamic>) {
            return encoding['contentUrl'] as String?;
          }
        }
      }
    } else if (subjectOf is Map<String, dynamic> && subjectOf['@type'] == '3DModel') {
      final encoding = subjectOf['encoding'];
      if (encoding is Map<String, dynamic>) {
        return encoding['contentUrl'] as String?;
      }
    }

    return null;
  }
}

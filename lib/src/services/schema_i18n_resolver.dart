import 'package:flutter/widgets.dart';

class SchemaI18nResolver {
  /// Resolves a localized string from a Schema.org JSON value.
  /// Handles:
  /// - Simple String: `"Product Name"`
  /// - Localized Object: `{"@value": "Product Name", "@language": "en"}`
  /// - List of Strings / Localized Objects: `[{"@value": "Name", "@language": "en"}, ...]`
  static String resolve(
    dynamic rawValue, {
    List<Locale>? preferredLocales,
    String defaultLanguage = 'en',
  }) {
    if (rawValue == null) return '';

    if (rawValue is String) return rawValue;

    if (rawValue is Map<String, dynamic>) {
      final value = rawValue['@value'] ?? rawValue['value'] ?? rawValue['name'];
      if (value is String) return value;
    }

    if (rawValue is List && rawValue.isNotEmpty) {
      final targetLocales = preferredLocales ?? _getSystemLocales();

      // 1. Exact locale match (e.g. "hi-IN" or "hi_IN")
      for (final locale in targetLocales) {
        final code = locale.toString().toLowerCase().replaceAll('_', '-');
        for (final item in rawValue) {
          if (_matchItemLanguage(item, code)) {
            final val = _extractItemValue(item);
            if (val != null) return val;
          }
        }
      }

      // 2. Language family match (e.g. "hi")
      for (final locale in targetLocales) {
        final langCode = locale.languageCode.toLowerCase();
        for (final item in rawValue) {
          if (_matchItemLanguage(item, langCode)) {
            final val = _extractItemValue(item);
            if (val != null) return val;
          }
        }
      }

      // 3. Fallback default language (e.g. "en")
      for (final item in rawValue) {
        if (_matchItemLanguage(item, defaultLanguage.toLowerCase())) {
          final val = _extractItemValue(item);
          if (val != null) return val;
        }
      }

      // 4. First available non-empty string
      for (final item in rawValue) {
        final val = _extractItemValue(item);
        if (val != null && val.isNotEmpty) return val;
      }
    }

    return rawValue.toString();
  }

  static List<Locale> _getSystemLocales() {
    try {
      final locales = WidgetsBinding.instance.platformDispatcher.locales;
      if (locales.isNotEmpty) return locales;
    } catch (_) {}
    return const [Locale('en')];
  }

  static bool _matchItemLanguage(dynamic item, String targetLang) {
    if (item is Map<String, dynamic>) {
      final itemLang = (item['@language'] ?? item['language'] as String?)
          ?.toString()
          .toLowerCase()
          .replaceAll('_', '-');
      if (itemLang != null && itemLang.startsWith(targetLang)) {
        return true;
      }
    }
    return false;
  }

  static String? _extractItemValue(dynamic item) {
    if (item is String) return item;
    if (item is Map<String, dynamic>) {
      final val = item['@value'] ?? item['value'] ?? item['name'];
      if (val is String) return val;
    }
    return null;
  }
}

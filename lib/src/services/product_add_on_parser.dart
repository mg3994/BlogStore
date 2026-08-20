import '../domain/models/product_add_on.dart';

class ProductAddOnParser {
  /// Extracts nested add-on groups from a product/service schema JSON object.
  static List<AddOnGroup> parseGroups(Map<String, dynamic>? schema) {
    if (schema == null) return const [];

    final rawGroups = schema['addOn'] ??
        schema['addOnGroups'] ??
        schema['hasMenuItemOption'] ??
        schema['additionalProperty'];

    return _parseGroupList(rawGroups);
  }

  static List<AddOnGroup> _parseGroupList(dynamic rawList) {
    if (rawList == null) return const [];

    final List<AddOnGroup> result = [];

    if (rawList is List) {
      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        final group = _parseSingleGroup(item, defaultId: 'group_$i');
        if (group != null) {
          result.add(group);
        }
      }
    } else if (rawList is Map<String, dynamic>) {
      final group = _parseSingleGroup(rawList, defaultId: 'group_0');
      if (group != null) {
        result.add(group);
      }
    }

    return result;
  }

  static AddOnGroup? _parseSingleGroup(dynamic item, {required String defaultId}) {
    if (item is! Map<String, dynamic>) return null;

    final id = item['id']?.toString() ?? item['@id']?.toString() ?? defaultId;
    final title = item['name'] ?? item['title'] ?? item['header'] ?? id;

    final minSelect = (item['minSelect'] as num?)?.toInt() ??
        (item['minQuantity'] as num?)?.toInt() ??
        ((item['isRequired'] == true) ? 1 : 0);

    final maxSelect = (item['maxSelect'] as num?)?.toInt() ??
        (item['maxQuantity'] as num?)?.toInt() ??
        1;

    final isRequired = (item['isRequired'] as bool?) ?? (minSelect > 0);

    final rawOptions = item['options'] ??
        item['hasMenuItemOption'] ??
        item['addOns'] ??
        item['value'];

    final options = _parseOptionList(rawOptions);

    return AddOnGroup(
      id: id,
      title: title,
      isRequired: isRequired,
      minSelect: minSelect,
      maxSelect: maxSelect,
      options: options,
    );
  }

  static List<AddOnOption> _parseOptionList(dynamic rawList) {
    if (rawList == null) return const [];

    final List<AddOnOption> result = [];

    if (rawList is List) {
      for (int i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        final opt = _parseSingleOption(item, defaultId: 'opt_$i');
        if (opt != null) {
          result.add(opt);
        }
      }
    } else if (rawList is Map<String, dynamic>) {
      final opt = _parseSingleOption(rawList, defaultId: 'opt_0');
      if (opt != null) {
        result.add(opt);
      }
    }

    return result;
  }

  static AddOnOption? _parseSingleOption(dynamic item, {required String defaultId}) {
    if (item is String) {
      return AddOnOption(id: defaultId, name: item);
    }

    if (item is! Map<String, dynamic>) return null;

    final id = item['id']?.toString() ?? item['@id']?.toString() ?? defaultId;
    final name = item['name'] ?? item['title'] ?? id;

    double priceAdjustment = 0.0;
    String currency = 'INR';

    final offers = item['offers'] ?? item['priceSpecification'];
    if (offers is Map<String, dynamic>) {
      priceAdjustment = (offers['price'] as num?)?.toDouble() ??
          (offers['priceAdjustment'] as num?)?.toDouble() ??
          0.0;
      currency = offers['priceCurrency']?.toString() ?? 'INR';
    } else {
      priceAdjustment = (item['priceAdjustment'] as num?)?.toDouble() ??
          (item['price'] as num?)?.toDouble() ??
          0.0;
    }

    final isDefault = (item['isDefault'] as bool?) ?? (item['selected'] as bool?) ?? false;

    final rawNested = item['nestedAddOnGroups'] ?? item['addOn'] ?? item['hasMenuItemOption'];
    final nestedGroups = _parseGroupList(rawNested);

    return AddOnOption(
      id: id,
      name: name,
      priceAdjustment: priceAdjustment,
      currency: currency,
      isDefault: isDefault,
      nestedGroups: nestedGroups,
    );
  }
}

class AddOnOption {
  final String id;
  final dynamic name; // String or Schema localized map/list
  final double priceAdjustment;
  final String currency;
  final bool isDefault;
  final List<AddOnGroup> nestedGroups;

  const AddOnOption({
    required this.id,
    required this.name,
    this.priceAdjustment = 0.0,
    this.currency = 'INR',
    this.isDefault = false,
    this.nestedGroups = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priceAdjustment': priceAdjustment,
        'currency': currency,
        'isDefault': isDefault,
        'nestedGroups': nestedGroups.map((g) => g.toJson()).toList(),
      };

  factory AddOnOption.fromJson(Map<String, dynamic> json) => AddOnOption(
        id: json['id'] as String? ?? '',
        name: json['name'],
        priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'INR',
        isDefault: json['isDefault'] as bool? ?? false,
        nestedGroups: (json['nestedGroups'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((g) => AddOnGroup.fromJson(g))
                .toList() ??
            const [],
      );
}

class AddOnGroup {
  final String id;
  final dynamic title; // String or Schema localized map/list
  final bool isRequired;
  final int minSelect;
  final int maxSelect;
  final List<AddOnOption> options;

  const AddOnGroup({
    required this.id,
    required this.title,
    this.isRequired = false,
    this.minSelect = 0,
    this.maxSelect = 1,
    this.options = const [],
  });

  bool get isSingleSelect => maxSelect == 1;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isRequired': isRequired,
        'minSelect': minSelect,
        'maxSelect': maxSelect,
        'options': options.map((o) => o.toJson()).toList(),
      };

  factory AddOnGroup.fromJson(Map<String, dynamic> json) => AddOnGroup(
        id: json['id'] as String? ?? '',
        title: json['title'],
        isRequired: json['isRequired'] as bool? ?? false,
        minSelect: (json['minSelect'] as num?)?.toInt() ?? 0,
        maxSelect: (json['maxSelect'] as num?)?.toInt() ?? 1,
        options: (json['options'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((o) => AddOnOption.fromJson(o))
                .toList() ??
            const [],
      );
}

class SelectedAddOn {
  final String groupId;
  final String optionId;
  final String optionName;
  final double priceAdjustment;
  final List<SelectedAddOn> selectedSubAddOns;

  const SelectedAddOn({
    required this.groupId,
    required this.optionId,
    required this.optionName,
    this.priceAdjustment = 0.0,
    this.selectedSubAddOns = const [],
  });

  double get totalPriceAdjustment {
    double total = priceAdjustment;
    for (final sub in selectedSubAddOns) {
      total += sub.totalPriceAdjustment;
    }
    return total;
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'optionId': optionId,
        'optionName': optionName,
        'priceAdjustment': priceAdjustment,
        'selectedSubAddOns': selectedSubAddOns.map((s) => s.toJson()).toList(),
      };

  factory SelectedAddOn.fromJson(Map<String, dynamic> json) => SelectedAddOn(
        groupId: json['groupId'] as String? ?? '',
        optionId: json['optionId'] as String? ?? '',
        optionName: json['optionName'] as String? ?? '',
        priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0.0,
        selectedSubAddOns: (json['selectedSubAddOns'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .map((s) => SelectedAddOn.fromJson(s))
                .toList() ??
            const [],
      );
}

class AmenityFeature {
  final String name;
  final String? value;

  const AmenityFeature({
    required this.name,
    this.value,
  });

  Map<String, dynamic> toJson() => {
        '@type': 'LocationFeatureSpecification',
        'name': name,
        if (value != null) 'value': value,
      };

  factory AmenityFeature.fromJson(Map<String, dynamic> json) => AmenityFeature(
        name: json['name'] as String? ?? json['@value'] as String? ?? '',
        value: json['value'] as String?,
      );
}

class Audience {
  final String? audienceType;
  final String? suggestedAge;

  const Audience({
    this.audienceType,
    this.suggestedAge,
  });

  Map<String, dynamic> toJson() => {
        '@type': 'PeopleAudience',
        if (audienceType != null) 'audienceType': audienceType,
        if (suggestedAge != null) 'suggestedAge': suggestedAge,
      };

  factory Audience.fromJson(Map<String, dynamic> json) => Audience(
        audienceType: json['audienceType'] as String? ?? json['name'] as String?,
        suggestedAge: json['suggestedAge'] is Map<String, dynamic>
            ? json['suggestedAge']['name'] ?? json['suggestedAge']['value']
            : json['suggestedAge'] as String?,
      );
}

class Certification {
  final String name;
  final String? issuedBy;

  const Certification({
    required this.name,
    this.issuedBy,
  });

  Map<String, dynamic> toJson() => {
        '@type': 'Certification',
        'name': name,
        if (issuedBy != null) 'issuedBy': issuedBy,
      };

  factory Certification.fromJson(Map<String, dynamic> json) => Certification(
        name: json['name'] as String? ?? json['certificationName'] as String? ?? '',
        issuedBy: json['issuedBy'] as String?,
      );
}

class OfferCatalog {
  final String name;
  final List<Map<String, dynamic>> itemListElement;

  const OfferCatalog({
    required this.name,
    this.itemListElement = const [],
  });

  Map<String, dynamic> toJson() => {
        '@type': 'OfferCatalog',
        'name': name,
        'itemListElement': itemListElement,
      };

  factory OfferCatalog.fromJson(Map<String, dynamic> json) => OfferCatalog(
        name: json['name'] as String? ?? '',
        itemListElement: (json['itemListElement'] as List?)
                ?.whereType<Map<String, dynamic>>()
                .toList() ??
            const [],
      );
}

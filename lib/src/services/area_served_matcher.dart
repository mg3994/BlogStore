import '../domain/models/location_model.dart';

class AreaServedMatcher {
  /// Checks if a schema's `areaServed` property matches the user's location.
  static bool isServiceable({
    required dynamic areaServed,
    required LocationModel? userLocation,
  }) {
    // If no specific areaServed defined, assume globally serviceable
    if (areaServed == null) return true;
    if (userLocation == null) return true;

    final targetAreas = <Map<String, dynamic>>[];

    if (areaServed is List) {
      for (final item in areaServed) {
        _normalizeArea(item, targetAreas);
      }
    } else {
      _normalizeArea(areaServed, targetAreas);
    }

    if (targetAreas.isEmpty) return true;

    for (final area in targetAreas) {
      if (_matchesLocation(area, userLocation)) {
        return true;
      }
    }

    return false;
  }

  static void _normalizeArea(dynamic area, List<Map<String, dynamic>> targetAreas) {
    if (area == null) return;

    if (area is String) {
      final trimmed = area.trim();
      if (trimmed.isNotEmpty) {
        targetAreas.add({'name': trimmed});
      }
    } else if (area is Map<String, dynamic>) {
      targetAreas.add(area);
    }
  }

  static bool _matchesLocation(Map<String, dynamic> area, LocationModel userLocation) {
    final type = (area['@type'] as String?)?.toLowerCase() ?? '';
    final name = (area['name'] as String?)?.trim() ?? '';
    final postalCode = (area['postalCode'] as String?)?.trim() ?? name;
    final addressCountry = area['addressCountry'] as String? ?? '';

    final userCity = userLocation.city?.trim() ?? '';
    final userState = userLocation.state?.trim() ?? '';
    final userCountry = userLocation.country?.trim() ?? '';
    final userPostalCode = userLocation.postalCode?.trim() ?? '';

    // 1. Country level matching
    if (type == 'country' || _isCountryName(name) || addressCountry.isNotEmpty) {
      final targetCountry = name.isNotEmpty ? name : addressCountry;
      if (userCountry.isNotEmpty && _equalsIgnoreCases(targetCountry, userCountry)) {
        return true;
      }
    }

    // 2. City level matching
    if (type == 'city') {
      if (userCity.isNotEmpty && _equalsIgnoreCases(name, userCity)) {
        return true;
      }
    }

    // 3. State level matching
    if (type == 'state' || type == 'administrativearea') {
      if (userState.isNotEmpty && _equalsIgnoreCases(name, userState)) {
        return true;
      }
      if (userCity.isNotEmpty && _equalsIgnoreCases(name, userCity)) {
        return true;
      }
    }

    // 4. Postal Code matching
    if (postalCode.isNotEmpty && userPostalCode.isNotEmpty) {
      if (_equalsIgnoreCases(postalCode, userPostalCode)) {
        return true;
      }
    }

    // 5. Fallback generic name matching against user's city, state, or country
    if (name.isNotEmpty) {
      if (userCity.isNotEmpty && _equalsIgnoreCases(name, userCity)) return true;
      if (userState.isNotEmpty && _equalsIgnoreCases(name, userState)) return true;
      if (userCountry.isNotEmpty && _equalsIgnoreCases(name, userCountry)) return true;
    }

    return false;
  }

  static bool _isCountryName(String name) {
    if (name.isEmpty) return false;
    final commonCountries = {'india', 'united states', 'usa', 'uk', 'canada', 'australia'};
    return commonCountries.contains(name.toLowerCase());
  }

  static bool _equalsIgnoreCases(String a, String b) {
    return a.toLowerCase().trim() == b.toLowerCase().trim();
  }
}

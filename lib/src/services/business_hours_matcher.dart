class BusinessHoursResult {
  final bool isOpen;
  final String? message;

  const BusinessHoursResult({
    required this.isOpen,
    this.message,
  });
}

class BusinessHoursMatcher {
  /// Evaluates whether a seller/business is currently open based on
  /// `openingHoursSpecification` and `specialOpeningHoursSpecification` schema JSON.
  static BusinessHoursResult isBusinessOpen(Map<String, dynamic>? sellerSchema, {DateTime? now}) {
    if (sellerSchema == null) {
      return const BusinessHoursResult(isOpen: true);
    }

    final currentTime = now ?? DateTime.now();
    final todayStr = '${currentTime.year.toString().padLeft(4, '0')}-'
        '${currentTime.month.toString().padLeft(2, '0')}-'
        '${currentTime.day.toString().padLeft(2, '0')}';
    final timeStr = '${currentTime.hour.toString().padLeft(2, '0')}:'
        '${currentTime.minute.toString().padLeft(2, '0')}';

    const dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final todayName = dayNames[currentTime.weekday - 1];

    // 1. Check Special Opening Hours (Holiday / Event Overrides)
    final special = _getArray(sellerSchema['specialOpeningHoursSpecification']);
    for (final s in special) {
      if (s is Map<String, dynamic>) {
        final validFrom = _getFirstString(s['validFrom']);
        final validThrough = _getFirstString(s['validThrough']);

        if (validFrom != null && validThrough != null && todayStr.compareTo(validFrom) >= 0 && todayStr.compareTo(validThrough) <= 0) {
          final opens = _getFirstString(s['opens']) ?? '00:00';
          final closes = _getFirstString(s['closes']) ?? '00:00';

          if (opens == '00:00' && closes == '00:00') {
            return const BusinessHoursResult(isOpen: false, message: 'Closed for Holiday/Event');
          }

          final isOpen = timeStr.compareTo(opens) >= 0 && timeStr.compareTo(closes) <= 0;
          return BusinessHoursResult(
            isOpen: isOpen,
            message: isOpen ? null : 'Closed (Special Hours: $opens-$closes)',
          );
        }
      }
    }

    // 2. Check Regular Opening Hours
    final regular = _getArray(sellerSchema['openingHoursSpecification']);
    if (regular.isEmpty) {
      return const BusinessHoursResult(isOpen: true);
    }

    Map<String, dynamic>? todayRegular;
    for (final r in regular) {
      if (r is Map<String, dynamic>) {
        final days = _getArray(r['dayOfWeek'])
            .map((d) => d.toString().replaceAll('https://schema.org/', '').replaceAll('http://schema.org/', ''))
            .toList();
        if (days.any((d) => d.toLowerCase() == todayName.toLowerCase())) {
          todayRegular = r;
          break;
        }
      }
    }

    if (todayRegular == null) {
      return BusinessHoursResult(isOpen: false, message: 'Closed on $todayName');
    }

    final opens = _getFirstString(todayRegular['opens']) ?? '00:00';
    final closes = _getFirstString(todayRegular['closes']) ?? '23:59';
    final isOpen = timeStr.compareTo(opens) >= 0 && timeStr.compareTo(closes) <= 0;

    return BusinessHoursResult(
      isOpen: isOpen,
      message: isOpen ? null : 'Closed (Opens at $opens)',
    );
  }

  static List<dynamic> _getArray(dynamic val) {
    if (val == null) return const [];
    if (val is List) return val;
    return [val];
  }

  static String? _getFirstString(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    if (val is List && val.isNotEmpty) return _getFirstString(val.first);
    if (val is Map<String, dynamic>) return _getFirstString(val['@value'] ?? val['name']);
    return val.toString();
  }
}

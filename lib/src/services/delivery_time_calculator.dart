class DeliveryTimeCalculator {
  /// Calculates total estimated delivery minutes by adding location travel minutes and max lead time minutes.
  static int calculateTotalMinutes({
    required int travelMinutes,
    required int maxLeadTimeMinutes,
  }) {
    final travel = travelMinutes < 0 ? 0 : travelMinutes;
    final leadTime = maxLeadTimeMinutes < 0 ? 0 : maxLeadTimeMinutes;
    return travel + leadTime;
  }

  /// Formats total minutes into a human-readable duration string (e.g. "35 mins", "1h", "1h 15m").
  static String formatDuration(int totalMinutes) {
    if (totalMinutes <= 0) return '0 mins';
    if (totalMinutes < 60) return '$totalMinutes mins';

    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;

    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  /// Parses travel duration text (e.g. "25 mins", "1 hour", "15") into minutes.
  static int parseTravelMinutes(String? durationText) {
    if (durationText == null || durationText.isEmpty) return 0;

    final lower = durationText.toLowerCase();
    final numStr = RegExp(r'\d+').firstMatch(lower)?.group(0);
    final val = int.tryParse(numStr ?? '') ?? 0;

    if (lower.contains('hour') || lower.contains('hr')) return val * 60;
    if (lower.contains('day')) return val * 24 * 60;
    return val;
  }
}

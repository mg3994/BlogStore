import 'dart:convert';
import 'package:dio/dio.dart';

class LocationMetricsResult {
  final bool success;
  final String? formattedAddress;
  final double? latitude;
  final double? longitude;
  final double? distanceMeters;
  final String? durationText;
  final Map<String, dynamic> addressDetails;

  const LocationMetricsResult({
    required this.success,
    this.formattedAddress,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.durationText,
    this.addressDetails = const {},
  });

  factory LocationMetricsResult.fromJson(Map<String, dynamic> json) => LocationMetricsResult(
        success: json['success'] as bool? ?? false,
        formattedAddress: json['formattedAddress'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble(),
        distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? (json['distance'] as num?)?.toDouble(),
        durationText: json['durationText'] as String?,
        addressDetails: (json['addressDetails'] as Map<String, dynamic>?) ?? const {},
      );
}

class AppsScriptRemoteDataSource {
  final Dio dio;
  String mapUrl;

  static const String defaultMapUrl =
      'https://script.google.com/macros/s/AKfycbyca4Xz_AE6Om1okIMf0TQ9EE9uIifQcVZhsDwnZK0K4weG7VD0w3jEzM0aCcuBeoWIIA/exec';

  AppsScriptRemoteDataSource({
    required this.dio,
    this.mapUrl = defaultMapUrl,
  });

  Future<List<String>> getPlaceSuggestions(String inputToken) async {
    try {
      final res = await _callAction('getPlaceSuggestions', {'inputToken': inputToken});
      if (res is Map<String, dynamic> && res['success'] == true) {
        final suggestions = res['suggestions'] as List?;
        return suggestions?.whereType<String>().toList() ?? const [];
      }
    } catch (_) {}
    return const [];
  }

  Future<LocationMetricsResult?> processLocationAndMetrics({
    required double originLat,
    required double originLng,
    required String destinationQuery,
  }) async {
    try {
      final res = await _callAction('processLocationAndMetrics', {
        'originLat': originLat,
        'originLng': originLng,
        'destinationQuery': destinationQuery,
      });
      if (res is Map<String, dynamic>) {
        return LocationMetricsResult.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  Future<LocationMetricsResult?> processPinDropMetrics({
    required double originLat,
    required double originLng,
    required double pinLat,
    required double pinLng,
  }) async {
    try {
      final res = await _callAction('processPinDropMetrics', {
        'originLat': originLat,
        'originLng': originLng,
        'pinLat': pinLat,
        'pinLng': pinLng,
      });
      if (res is Map<String, dynamic>) {
        return LocationMetricsResult.fromJson(res);
      }
    } catch (_) {}
    return null;
  }

  Future<dynamic> _callAction(String action, Map<String, dynamic> params) async {
    final payload = jsonEncode({'action': action, 'params': params});

    final res = await dio.post(
      mapUrl,
      data: payload,
      options: Options(
        headers: {'Content-Type': 'text/plain;charset=utf-8'},
      ),
    );

    if (res.data is String) {
      return jsonDecode(res.data);
    }
    return res.data;
  }
}

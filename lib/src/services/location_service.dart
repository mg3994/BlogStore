import 'dart:convert';
import 'package:dio/dio.dart';
import '../domain/models/location_model.dart';

typedef CustomLocationFetcher = Future<String?> Function(String url, {Map<String, String>? headers});

class LocationService {
  final Dio? dio;
  final CustomLocationFetcher? customFetcher;

  LocationModel? _currentLocation;

  LocationService({this.dio, this.customFetcher});

  LocationModel? get currentLocation => _currentLocation;

  void setLocation(LocationModel location) {
    _currentLocation = location;
  }

  void clearLocation() {
    _currentLocation = null;
  }

  /// Helper method to create location manually by city / postal code / state / country
  void setManualLocation({
    String? city,
    String? state,
    String? country,
    String? postalCode,
    double? latitude,
    double? longitude,
  }) {
    _currentLocation = LocationModel(
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Reverse geocodes latitude and longitude to resolve city, state, and postal code using Nominatim.
  Future<LocationModel?> reverseGeocode(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final bodyText = await _fetchUrlText(url);
      if (bodyText != null && bodyText.isNotEmpty) {
        final data = jsonDecode(bodyText);
        if (data is Map<String, dynamic> && data['address'] is Map<String, dynamic>) {
          final address = data['address'] as Map<String, dynamic>;
          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state_district'] ??
              address['county'];
          final state = address['state'] as String?;
          final country = address['country'] as String?;
          final postalCode = address['postcode'] as String?;

          final model = LocationModel(
            city: city?.toString(),
            state: state,
            country: country,
            postalCode: postalCode,
            latitude: latitude,
            longitude: longitude,
          );
          _currentLocation = model;
          return model;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Looks up a postal code / PIN to resolve latitude, longitude, and city name using Nominatim.
  Future<LocationModel?> lookupPin(String pin, {String countryName = 'India'}) async {
    final encodedPin = Uri.encodeComponent(pin);
    final encodedCountry = Uri.encodeComponent(countryName);
    final url =
        'https://nominatim.openstreetmap.org/search?postalcode=$encodedPin&country=$encodedCountry&format=json&addressdetails=1';

    try {
      final bodyText = await _fetchUrlText(url);
      if (bodyText != null && bodyText.isNotEmpty) {
        final data = jsonDecode(bodyText);
        if (data is List && data.isNotEmpty) {
          final first = data.first as Map<String, dynamic>;
          final lat = double.tryParse(first['lat']?.toString() ?? '');
          final lon = double.tryParse(first['lon']?.toString() ?? '');
          final address = first['address'] as Map<String, dynamic>? ?? {};

          final city = address['city'] ??
              address['town'] ??
              address['village'] ??
              address['state_district'] ??
              address['county'];
          final state = address['state'] as String?;
          final country = address['country'] as String? ?? countryName;

          final model = LocationModel(
            city: city?.toString(),
            state: state,
            country: country,
            postalCode: pin,
            latitude: lat,
            longitude: lon,
          );
          _currentLocation = model;
          return model;
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _fetchUrlText(String url) async {
    final headers = {'User-Agent': 'Antinna-Blogger-Engine/1.0'};
    if (customFetcher != null) {
      return await customFetcher!(url, headers: headers);
    }
    if (dio != null) {
      final res = await dio!.get(url, options: Options(headers: headers));
      if (res.statusCode == 200) {
        return res.data is String ? res.data : jsonEncode(res.data);
      }
    }
    return null;
  }
}

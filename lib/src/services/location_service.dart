import '../domain/models/location_model.dart';

class LocationService {
  LocationModel? _currentLocation;

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
}

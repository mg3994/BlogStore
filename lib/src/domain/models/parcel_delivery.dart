class PostalAddress {
  final String? extendedAddress;
  final String? streetAddress;
  final String? addressLocality;
  final String? addressRegion;
  final String? postalCode;
  final String addressCountry;

  const PostalAddress({
    this.extendedAddress,
    this.streetAddress,
    this.addressLocality,
    this.addressRegion,
    this.postalCode,
    this.addressCountry = 'IN',
  });

  Map<String, dynamic> toJson() => {
        '@type': 'PostalAddress',
        if (extendedAddress != null) 'extendedAddress': extendedAddress,
        if (streetAddress != null) 'streetAddress': streetAddress,
        if (addressLocality != null) 'addressLocality': addressLocality,
        if (addressRegion != null) 'addressRegion': addressRegion,
        if (postalCode != null) 'postalCode': postalCode,
        'addressCountry': addressCountry,
      };

  factory PostalAddress.fromJson(Map<String, dynamic> json) => PostalAddress(
        extendedAddress: json['extendedAddress'] as String?,
        streetAddress: json['streetAddress'] as String?,
        addressLocality: json['addressLocality'] as String?,
        addressRegion: json['addressRegion'] as String?,
        postalCode: json['postalCode'] as String?,
        addressCountry: json['addressCountry'] as String? ?? 'IN',
      );
}

class ParcelDelivery {
  final String deliveryName;
  final PostalAddress deliveryAddress;
  final double latitude;
  final double longitude;

  const ParcelDelivery({
    this.deliveryName = 'Standard Handheld Delivery',
    required this.deliveryAddress,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        '@type': 'ParcelDelivery',
        'deliveryName': deliveryName,
        'deliveryAddress': deliveryAddress.toJson(),
        'deliveryStatus': {
          '@type': 'DeliveryEvent',
          'name': 'Final Destination Drop-off',
          'location': {
            '@type': 'Place',
            'name': 'Exact Delivery Coordinates',
            'geo': {
              '@type': 'GeoCoordinates',
              'latitude': latitude.toString(),
              'longitude': longitude.toString(),
            }
          }
        }
      };

  factory ParcelDelivery.fromJson(Map<String, dynamic> json) {
    final addrJson = json['deliveryAddress'] as Map<String, dynamic>? ?? {};
    double lat = 0.0;
    double lng = 0.0;

    final status = json['deliveryStatus'] as Map<String, dynamic>?;
    final location = status?['location'] as Map<String, dynamic>?;
    final geo = location?['geo'] as Map<String, dynamic>?;

    if (geo != null) {
      lat = double.tryParse(geo['latitude']?.toString() ?? '0') ?? 0.0;
      lng = double.tryParse(geo['longitude']?.toString() ?? '0') ?? 0.0;
    }

    return ParcelDelivery(
      deliveryName: json['deliveryName'] as String? ?? 'Standard Handheld Delivery',
      deliveryAddress: PostalAddress.fromJson(addrJson),
      latitude: lat,
      longitude: lng,
    );
  }
}
